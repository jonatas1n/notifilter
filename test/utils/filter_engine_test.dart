import 'package:flutter_test/flutter_test.dart';

import 'package:notifilter/models/filter_match_type.dart';
import 'package:notifilter/models/filter_rule.dart';
import 'package:notifilter/models/filter_rule_action.dart';
import 'package:notifilter/models/incoming_notification.dart';

import 'package:notifilter/utils/filter_engine.dart';

void main() {
  group('filter_engine', () {
    test('blocks when keyword rule matches', () {
      const notification = IncomingNotification(
        key: '1',
        packageName: 'com.chat',
        title: 'Shop',
        text: 'Big sale today',
        postTime: 0,
      );

      final action = evaluateKeywordRules(
        notification: notification,
        rules: const [
          FilterRule(
            id: '1',
            keyword: 'sale',
            matchType: FilterMatchType.contains,
            action: FilterRuleAction.block,
          ),
        ],
      );

      expect(action, FilterRuleAction.block);
    });

    test('allow rule wins over later block rule', () {
      const notification = IncomingNotification(
        key: '1',
        packageName: 'com.chat',
        title: 'Team',
        text: 'sale for VIP',
        postTime: 0,
      );

      final action = evaluateKeywordRules(
        notification: notification,
        rules: const [
          FilterRule(
            id: 'allow',
            keyword: 'VIP',
            matchType: FilterMatchType.contains,
            action: FilterRuleAction.allow,
          ),
          FilterRule(
            id: 'block',
            keyword: 'sale',
            matchType: FilterMatchType.contains,
            action: FilterRuleAction.block,
          ),
        ],
      );

      expect(action, FilterRuleAction.allow);
    });

    test('respects optional package filter', () {
      const notification = IncomingNotification(
        key: '1',
        packageName: 'com.other',
        title: 'Promo',
        text: 'sale now',
        postTime: 0,
      );

      final action = evaluateKeywordRules(
        notification: notification,
        rules: const [
          FilterRule(
            id: '1',
            keyword: 'sale',
            matchType: FilterMatchType.contains,
            action: FilterRuleAction.block,
            packageName: 'com.chat',
          ),
        ],
      );

      expect(action, isNull);
    });
  });
}
