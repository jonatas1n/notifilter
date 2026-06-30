import '../models/incoming_notification.dart';
import '../utils/notification_grouper.dart';

String contactGroupKeyForNotification(IncomingNotification notification) {
  return buildNotificationGroupKey(
    packageName: notification.packageName,
    title: notification.title,
  );
}
