import 'package:flutter_test/flutter_test.dart';

import 'package:prio/models/contact_importance_level.dart';
import 'package:prio/models/notification_decision.dart';
import 'package:prio/utils/contact_importance_policy.dart';

void main() {
  group('contact_importance_policy', () {
    test('high importance allows during silence windows', () {
      final decision = decisionFromContactImportance(
        level: ContactImportanceLevel.highImportance,
        evaluationTime: DateTime(2026, 6, 29, 23, 0),
        hideUntil: null,
        inQuietSchedule: true,
        inCondensedHold: true,
        category: null,
        body: 'hello',
      );

      expect(decision?.type, NotificationDecisionType.show);
    });

    test('hide temporarily holds until expiry', () {
      final decision = decisionFromContactImportance(
        level: ContactImportanceLevel.hideTemporarily,
        evaluationTime: DateTime(2026, 6, 29, 12, 0),
        hideUntil: DateTime(2026, 6, 30, 12, 0),
        inQuietSchedule: false,
        inCondensedHold: false,
        category: 'msg',
        body: 'urgent',
      );

      expect(decision?.type, NotificationDecisionType.hold);
      expect(decision?.reason, contains('Ocultar'));
    });

    test('hide temporarily expires and returns null override', () {
      final expired = decisionFromContactImportance(
        level: ContactImportanceLevel.hideTemporarily,
        evaluationTime: DateTime(2026, 7, 1, 12, 0),
        hideUntil: DateTime(2026, 6, 30, 12, 0),
        inQuietSchedule: false,
        inCondensedHold: false,
        category: null,
        body: 'hello',
      );

      expect(expired, isNull);
    });

    test('reduce noise holds during quiet unless direct category', () {
      final hold = decisionFromContactImportance(
        level: ContactImportanceLevel.reduceNoise,
        evaluationTime: DateTime(2026, 6, 29, 12, 0),
        hideUntil: null,
        inQuietSchedule: true,
        inCondensedHold: false,
        category: 'promo',
        body: 'sale',
      );

      expect(hold?.type, NotificationDecisionType.hold);

      final allowMsg = decisionFromContactImportance(
        level: ContactImportanceLevel.reduceNoise,
        evaluationTime: DateTime(2026, 6, 29, 12, 0),
        hideUntil: null,
        inQuietSchedule: true,
        inCondensedHold: false,
        category: 'msg',
        body: 'ping',
      );

      expect(allowMsg, isNull);
    });
  });
}
