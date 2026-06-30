import '../core/logging/app_logger.dart';
import '../models/app_settings.dart';
import '../models/time_window.dart';
import '../repositories/notification_inbox_repository.dart';
import '../repositories/settings_repository.dart';
import '../utils/digest_window_evaluator.dart';

/// Releases held inbox items when a condensed digest window opens.
class DigestDeliveryService {
  DigestDeliveryService({
    required SettingsRepository settingsRepository,
    required NotificationInboxRepository inboxRepository,
  })  : _settingsRepository = settingsRepository,
        _inboxRepository = inboxRepository;

  final SettingsRepository _settingsRepository;
  final NotificationInboxRepository _inboxRepository;

  bool _wasInsideDigestWindow = false;

  Future<int> evaluateDigestTransition(DateTime evaluationTime) async {
    final settings = _settingsRepository.loadAppSettings();
    final digestWindows = _settingsRepository.loadDigestWindows();

    final insideDigest = _isInsideDigestWindow(
      settings: settings,
      digestWindows: digestWindows,
      evaluationTime: evaluationTime,
    );

    if (_wasInsideDigestWindow == insideDigest) {
      return 0;
    }

    _wasInsideDigestWindow = insideDigest;

    if (!insideDigest) {
      return 0;
    }

    final releasedCount =
        await _inboxRepository.releaseHeldNotificationsForDigest(evaluationTime);

    if (releasedCount > 0) {
      appLogger.i(
        'Digest window opened: released $releasedCount held notification(s) to inbox',
      );
    }

    return releasedCount;
  }

  bool _isInsideDigestWindow({
    required AppSettings settings,
    required List<TimeWindow> digestWindows,
    required DateTime evaluationTime,
  }) {
    if (!settings.condensedInboxEnabled) {
      return false;
    }

    return isWithinDigestWindow(
      dateTime: evaluationTime,
      digestWindows: digestWindows,
    );
  }
}
