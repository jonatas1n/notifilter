import 'dart:async';

import '../core/logging/app_logger.dart';
import '../models/inbox_delivery_state.dart';
import '../models/incoming_notification.dart';
import '../models/notification_decision.dart';
import '../models/stored_notification.dart';
import '../repositories/contact_importance_repository.dart';
import '../repositories/notification_inbox_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/digest_delivery_service.dart';
import '../services/notification_bridge_service.dart';
import '../services/notification_policy_engine.dart';
import '../utils/contact_group_key.dart';
import '../utils/emergency_insistence_detector.dart';

class NotificationOrchestratorService {
  NotificationOrchestratorService({
    required NotificationBridgeService bridgeService,
    required SettingsRepository settingsRepository,
    required NotificationInboxRepository inboxRepository,
    required ContactImportanceRepository contactImportanceRepository,
    required DigestDeliveryService digestDeliveryService,
  })  : _bridgeService = bridgeService,
        _settingsRepository = settingsRepository,
        _inboxRepository = inboxRepository,
        _contactImportanceRepository = contactImportanceRepository,
        _digestDeliveryService = digestDeliveryService,
        _policyEngine = const NotificationPolicyEngine();

  final NotificationBridgeService _bridgeService;
  final SettingsRepository _settingsRepository;
  final NotificationInboxRepository _inboxRepository;
  final ContactImportanceRepository _contactImportanceRepository;
  final DigestDeliveryService _digestDeliveryService;
  final NotificationPolicyEngine _policyEngine;

  List<EmergencyInsistenceEvent> _recentInsistenceEvents = [];
  Timer? _digestTimer;

  Future<void> startProcessing() async {
    await checkDigestWindows();

    _digestTimer?.cancel();
    _digestTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        checkDigestWindows().catchError((Object error, StackTrace stackTrace) {
          appLogger.e(
            'Digest window check failed',
            error: error,
            stackTrace: stackTrace,
          );
          return 0;
        });
      },
    );

    _bridgeService.watchNotifications().listen(
      _handleIncomingNotification,
      onError: (Object error, StackTrace stackTrace) {
        appLogger.e(
          'Notification processing failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<int> checkDigestWindows() async {
    return _digestDeliveryService.evaluateDigestTransition(DateTime.now());
  }

  void dispose() {
    _digestTimer?.cancel();
  }

  Future<void> _handleIncomingNotification(
    IncomingNotification notification,
  ) async {
    if (notification.eventType == 'removed') {
      return;
    }

    if (notification.key.isEmpty) {
      return;
    }

    await checkDigestWindows();

    final evaluationTime = DateTime.now();
    final groupKey = contactGroupKeyForNotification(notification);

    await _contactImportanceRepository.revertExpiredHideToNormal(
      groupKey: groupKey,
      evaluationTime: evaluationTime,
    );

    final decision = _evaluateNotification(
      notification: notification,
      evaluationTime: evaluationTime,
      groupKey: groupKey,
    );

    _recentInsistenceEvents = appendInsistenceEvent(
      recentEvents: _recentInsistenceEvents,
      notification: notification,
      settings: _settingsRepository.loadEmergencySettings(),
    );

    if (decision.shouldSuppress) {
      final cancelled = await _bridgeService.cancelNotification(notification.key);
      if (!cancelled) {
        appLogger.w(
          'Native suppress/cancel failed for ${notification.key} — notification may remain visible briefly',
        );
      }
    }

    await _inboxRepository.insertNotification(
      _buildStoredNotification(
        notification: notification,
        decision: decision,
        evaluationTime: evaluationTime,
      ),
    );
  }

  NotificationDecision _evaluateNotification({
    required IncomingNotification notification,
    required DateTime evaluationTime,
    required String groupKey,
  }) {
    final importance = _contactImportanceRepository.levelForGroup(groupKey);
    final hideUntil = _contactImportanceRepository.hideUntilForGroup(groupKey);

    return _policyEngine.evaluate(
      notification: notification,
      rules: _settingsRepository.loadFilterRules(),
      quietSchedules: _settingsRepository.loadQuietSchedules(),
      digestWindows: _settingsRepository.loadDigestWindows(),
      settings: _settingsRepository.loadAppSettings(),
      emergencySettings: _settingsRepository.loadEmergencySettings(),
      recentInsistenceEvents: _recentInsistenceEvents,
      evaluationTime: evaluationTime,
      contactImportance: importance,
      contactHideUntil: hideUntil,
    );
  }

  StoredNotification _buildStoredNotification({
    required IncomingNotification notification,
    required NotificationDecision decision,
    required DateTime evaluationTime,
  }) {
    final isHeld = decision.shouldSuppress;

    return StoredNotification(
      notificationKey: notification.key,
      packageName: notification.packageName,
      title: notification.title,
      text: notification.combinedBody,
      postTime: notification.postTime,
      receivedAt: evaluationTime,
      wasEmergencyBreakthrough: decision.isEmergencyBreakthrough,
      decisionReason: decision.reason,
      isRead: false,
      isHeldSuppressed: isHeld,
      deliveryState: isHeld
          ? InboxDeliveryState.held
          : InboxDeliveryState.shownLive,
      deliveredAt: null,
    );
  }
}
