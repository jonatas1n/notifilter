import '../models/notification_inbox_group.dart';
import '../models/stored_notification.dart';

String normalizeSenderLabel(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return 'Desconhecido';
  }
  return trimmed;
}

String buildNotificationGroupKey({
  required String packageName,
  required String title,
}) {
  final sender = normalizeSenderLabel(title).toLowerCase();
  return '$packageName::$sender';
}

List<NotificationInboxGroup> groupStoredNotifications(
  List<StoredNotification> notifications,
) {
  final grouped = <String, List<StoredNotification>>{};

  for (final notification in notifications) {
    final key = buildNotificationGroupKey(
      packageName: notification.packageName,
      title: notification.title,
    );
    grouped.putIfAbsent(key, () => []).add(notification);
  }

  final groups = grouped.entries.map((entry) {
    final items = List<StoredNotification>.from(entry.value)
      ..sort((a, b) => b.postTime.compareTo(a.postTime));

    final latest = items.first;
    final unreadCount = items.where((item) => !item.isRead).length;

    return NotificationInboxGroup(
      groupKey: entry.key,
      displayName: normalizeSenderLabel(latest.title),
      packageName: latest.packageName,
      notifications: items,
      unreadCount: unreadCount,
      latestPostTime: latest.postTime,
    );
  }).toList();

  groups.sort((a, b) => b.latestPostTime.compareTo(a.latestPostTime));
  return groups;
}

int countFilteredNotifications(List<StoredNotification> notifications) {
  return notifications
      .where(
        (item) =>
            item.decisionReason.contains('Blocked') ||
            item.decisionReason.contains('silence') ||
            item.decisionReason.contains('Condensed'),
      )
      .length;
}

int countFocusedNotifications(List<StoredNotification> notifications) {
  return notifications
      .where(
        (item) =>
            item.wasEmergencyBreakthrough ||
            item.decisionReason == 'Allowed',
      )
      .length;
}

bool shouldSuggestContactUnification(List<NotificationInboxGroup> groups) {
  final namesByNormalized = <String, Set<String>>{};

  for (final group in groups) {
    final normalized = group.displayName.toLowerCase();
    namesByNormalized.putIfAbsent(normalized, () => {}).add(group.packageName);
  }

  for (final packages in namesByNormalized.values) {
    if (packages.length >= 2) {
      return true;
    }
  }
  return false;
}
