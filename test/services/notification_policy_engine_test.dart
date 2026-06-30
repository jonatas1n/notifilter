import 'package:flutter_test/flutter_test.dart';

import 'package:notifilter/models/app_settings.dart';
import 'package:notifilter/models/contact_importance_level.dart';
import 'package:notifilter/models/emergency_settings.dart';
import 'package:notifilter/models/filter_match_type.dart';
import 'package:notifilter/models/filter_rule.dart';
import 'package:notifilter/models/filter_rule_action.dart';
import 'package:notifilter/models/incoming_notification.dart';
import 'package:notifilter/models/notification_decision.dart';
import 'package:notifilter/models/time_window.dart';
import 'package:notifilter/services/notification_policy_engine.dart';
import 'package:notifilter/utils/emergency_insistence_detector.dart';

void main() {
  group('NotificationPolicyEngine', () {
    const engine = NotificationPolicyEngine();

    const baseNotification = IncomingNotification(
      key: '1',
      packageName: 'com.chat',
      title: 'Alex',
      text: 'hello',
      postTime: 0,
    );

    NotificationDecision evaluate({
      required IncomingNotification notification,
      List<FilterRule> rules = const [],
      List<TimeWindow> quietSchedules = const [],
      List<TimeWindow> digestWindows = const [],
      AppSettings settings = AppSettings.defaults,
      EmergencySettings emergencySettings = EmergencySettings.defaults,
      List<EmergencyInsistenceEvent> recentInsistenceEvents = const [],
      DateTime? evaluationTime,
      ContactImportanceLevel contactImportance = ContactImportanceLevel.normal,
      DateTime? contactHideUntil,
    }) {
      return engine.evaluate(
        notification: notification,
        rules: rules,
        quietSchedules: quietSchedules,
        digestWindows: digestWindows,
        settings: settings,
        emergencySettings: emergencySettings,
        recentInsistenceEvents: recentInsistenceEvents,
        evaluationTime: evaluationTime ?? DateTime(2026, 6, 29, 12, 0),
        contactImportance: contactImportance,
        contactHideUntil: contactHideUntil,
      );
    }

    test('emergency breakthrough overrides block rule', () {
      const recentEvents = [
        EmergencyInsistenceEvent(
          sourceIdentifier: 'com.chat::Alex',
          postTime: 300000,
        ),
        EmergencyInsistenceEvent(
          sourceIdentifier: 'com.chat::Alex',
          postTime: 450000,
        ),
      ];

      final decision = evaluate(
        notification: const IncomingNotification(
          key: '1',
          packageName: 'com.chat',
          title: 'Alex',
          text: 'urgent ping',
          postTime: 600000,
        ),
        rules: const [
          FilterRule(
            id: 'block-all',
            keyword: 'ping',
            matchType: FilterMatchType.contains,
            action: FilterRuleAction.block,
          ),
        ],
        recentInsistenceEvents: recentEvents,
        evaluationTime: DateTime(2026, 6, 29, 12, 0),
        emergencySettings:
            const EmergencySettings(thresholdCount: 3, windowMinutes: 10),
      );

      expect(decision.isEmergencyBreakthrough, isTrue);
      expect(decision.type, NotificationDecisionType.show);
    });

    test('quiet schedule holds notification', () {
      const quiet = TimeWindow(
        id: '1',
        startMinutes: 0,
        endMinutes: 24 * 60,
        weekdays: [1, 2, 3, 4, 5, 6, 7],
      );

      final decision = evaluate(
        notification: baseNotification,
        quietSchedules: const [quiet],
        evaluationTime: DateTime(2026, 6, 29, 15, 0),
      );

      expect(decision.type, NotificationDecisionType.hold);
      expect(decision.reason, contains('silence'));
    });

    test('high importance bypasses quiet schedule', () {
      const quiet = TimeWindow(
        id: '1',
        startMinutes: 0,
        endMinutes: 24 * 60,
        weekdays: [1, 2, 3, 4, 5, 6, 7],
      );

      final decision = evaluate(
        notification: baseNotification,
        quietSchedules: const [quiet],
        contactImportance: ContactImportanceLevel.highImportance,
      );

      expect(decision.type, NotificationDecisionType.show);
    });

    test('high importance bypasses keyword block', () {
      final decision = evaluate(
        notification: baseNotification,
        rules: const [
          FilterRule(
            id: '1',
            keyword: 'hello',
            matchType: FilterMatchType.contains,
            action: FilterRuleAction.block,
          ),
        ],
        contactImportance: ContactImportanceLevel.highImportance,
      );

      expect(decision.type, NotificationDecisionType.show);
    });

    test('condensed mode holds outside digest window', () {
      const digest = TimeWindow(
        id: '1',
        startMinutes: 12 * 60,
        endMinutes: 13 * 60,
        weekdays: [1, 2, 3, 4, 5, 6, 7],
      );

      final decision = evaluate(
        notification: baseNotification,
        digestWindows: const [digest],
        settings: AppSettings.defaults.copyWith(condensedInboxEnabled: true),
        evaluationTime: DateTime(2026, 6, 29, 9, 0),
      );

      expect(decision.type, NotificationDecisionType.hold);
      expect(decision.reason, contains('Condensed'));
    });
  });
}
