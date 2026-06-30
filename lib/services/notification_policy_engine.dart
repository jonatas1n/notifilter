import '../models/app_settings.dart';
import '../models/contact_importance_level.dart';
import '../models/emergency_settings.dart';
import '../models/filter_rule.dart';
import '../models/filter_rule_action.dart';
import '../models/incoming_notification.dart';
import '../models/notification_decision.dart';
import '../models/time_window.dart';
import '../utils/contact_importance_policy.dart';
import '../utils/digest_window_evaluator.dart';
import '../utils/emergency_insistence_detector.dart';
import '../utils/filter_engine.dart';
import '../utils/schedule_evaluator.dart';

class NotificationPolicyEngine {
  const NotificationPolicyEngine();

  NotificationDecision evaluate({
    required IncomingNotification notification,
    required List<FilterRule> rules,
    required List<TimeWindow> quietSchedules,
    required List<TimeWindow> digestWindows,
    required AppSettings settings,
    required EmergencySettings emergencySettings,
    required List<EmergencyInsistenceEvent> recentInsistenceEvents,
    required DateTime evaluationTime,
    required ContactImportanceLevel contactImportance,
    required DateTime? contactHideUntil,
  }) {
    final emergency = isEmergencyInsistence(
      notification: notification,
      recentEvents: recentInsistenceEvents,
      settings: emergencySettings,
    );

    if (emergency) {
      return const NotificationDecision(
        type: NotificationDecisionType.show,
        reason: 'Emergency insistence breakthrough',
        isEmergencyBreakthrough: true,
      );
    }

    final inQuietSchedule = isDateTimeWithinAnyTimeWindow(
      dateTime: evaluationTime,
      windows: quietSchedules,
    );

    final inCondensedHold = shouldHoldForCondensedInbox(
      condensedInboxEnabled: settings.condensedInboxEnabled,
      dateTime: evaluationTime,
      digestWindows: digestWindows,
    );

    final effectiveImportance = hasHideTemporarilyExpired(
      level: contactImportance,
      evaluationTime: evaluationTime,
      hideUntil: contactHideUntil,
    )
        ? ContactImportanceLevel.normal
        : contactImportance;

    final effectiveHideUntil = hasHideTemporarilyExpired(
      level: contactImportance,
      evaluationTime: evaluationTime,
      hideUntil: contactHideUntil,
    )
        ? null
        : contactHideUntil;

    final importanceDecision = decisionFromContactImportance(
      level: effectiveImportance,
      evaluationTime: evaluationTime,
      hideUntil: effectiveHideUntil,
      inQuietSchedule: inQuietSchedule,
      inCondensedHold: inCondensedHold,
      category: notification.category,
      body: notification.combinedBody,
    );

    if (importanceDecision != null) {
      return importanceDecision;
    }

    final keywordAction = evaluateKeywordRules(
      notification: notification,
      rules: rules,
    );

    if (keywordAction == FilterRuleAction.block) {
      return const NotificationDecision(
        type: NotificationDecisionType.hold,
        reason: 'Blocked by keyword rule',
      );
    }

    if (inQuietSchedule) {
      return const NotificationDecision(
        type: NotificationDecisionType.hold,
        reason: 'Scheduled silence window',
      );
    }

    if (inCondensedHold) {
      return const NotificationDecision(
        type: NotificationDecisionType.hold,
        reason: 'Condensed inbox outside digest window',
      );
    }

    return const NotificationDecision(
      type: NotificationDecisionType.show,
      reason: 'Allowed',
    );
  }
}
