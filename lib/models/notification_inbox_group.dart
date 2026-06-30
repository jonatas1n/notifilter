import 'stored_notification.dart';

class NotificationInboxGroup {
  const NotificationInboxGroup({
    required this.groupKey,
    required this.displayName,
    required this.packageName,
    required this.notifications,
    required this.unreadCount,
    required this.latestPostTime,
  });

  final String groupKey;
  final String displayName;
  final String packageName;
  final List<StoredNotification> notifications;
  final int unreadCount;
  final int latestPostTime;

  StoredNotification? get latestNotification {
    if (notifications.isEmpty) {
      return null;
    }
    return notifications.first;
  }

  String get previewText {
    final latest = latestNotification;
    if (latest == null) {
      return '';
    }
    return latest.text;
  }
}
