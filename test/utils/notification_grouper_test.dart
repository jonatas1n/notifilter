import 'package:flutter_test/flutter_test.dart';

import 'package:prio/models/inbox_delivery_state.dart';
import 'package:prio/models/stored_notification.dart';
import 'package:prio/utils/notification_grouper.dart';

StoredNotification _item({
  required String key,
  required String packageName,
  required String title,
  required int postTime,
  String reason = 'Blocked by keyword rule',
}) {
  return StoredNotification(
    notificationKey: key,
    packageName: packageName,
    title: title,
    text: 'body',
    postTime: postTime,
    receivedAt: DateTime.fromMillisecondsSinceEpoch(postTime),
    wasEmergencyBreakthrough: false,
    decisionReason: reason,
    isRead: false,
    isHeldSuppressed: reason.contains('Blocked') || reason.contains('silence'),
    deliveryState: InboxDeliveryState.held,
  );
}

void main() {
  group('notification_grouper', () {
    test('groups by package and sender title', () {
      final groups = groupStoredNotifications([
        _item(key: '1', packageName: 'com.chat', title: 'Maria', postTime: 100),
        _item(key: '2', packageName: 'com.chat', title: 'Maria', postTime: 200),
        _item(key: '3', packageName: 'com.mail', title: 'Maria', postTime: 300),
      ]);

      expect(groups.length, 2);
      final chatGroup = groups.firstWhere((g) => g.packageName == 'com.chat');
      expect(chatGroup.displayName, 'Maria');
      expect(chatGroup.unreadCount, 2);
    });

    test('detects contact unification suggestion across apps', () {
      final groups = groupStoredNotifications([
        _item(key: '1', packageName: 'com.a', title: 'João', postTime: 1),
        _item(key: '2', packageName: 'com.b', title: 'João', postTime: 2),
      ]);

      expect(shouldSuggestContactUnification(groups), isTrue);
    });

    test('counts filtered and focused notifications', () {
      final items = [
        _item(key: '1', packageName: 'a', title: 't', postTime: 1, reason: 'Blocked by keyword rule'),
        _item(key: '2', packageName: 'a', title: 't', postTime: 2, reason: 'Allowed'),
      ];

      expect(countFilteredNotifications(items), 1);
      expect(countFocusedNotifications(items), 1);
    });
  });
}
