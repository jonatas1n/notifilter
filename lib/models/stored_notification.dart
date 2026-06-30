import 'inbox_delivery_state.dart';

class StoredNotification {
  const StoredNotification({
    this.id,
    required this.notificationKey,
    required this.packageName,
    required this.title,
    required this.text,
    required this.postTime,
    required this.receivedAt,
    required this.wasEmergencyBreakthrough,
    required this.decisionReason,
    required this.isRead,
    required this.isHeldSuppressed,
    required this.deliveryState,
    this.deliveredAt,
  });

  final int? id;
  final String notificationKey;
  final String packageName;
  final String title;
  final String text;
  final int postTime;
  final DateTime receivedAt;
  final bool wasEmergencyBreakthrough;
  final String decisionReason;
  final bool isRead;
  final bool isHeldSuppressed;
  final InboxDeliveryState deliveryState;
  final DateTime? deliveredAt;

  StoredNotification copyWith({
    int? id,
    bool? isRead,
    InboxDeliveryState? deliveryState,
    DateTime? deliveredAt,
  }) {
    return StoredNotification(
      id: id ?? this.id,
      notificationKey: notificationKey,
      packageName: packageName,
      title: title,
      text: text,
      postTime: postTime,
      receivedAt: receivedAt,
      wasEmergencyBreakthrough: wasEmergencyBreakthrough,
      decisionReason: decisionReason,
      isRead: isRead ?? this.isRead,
      isHeldSuppressed: isHeldSuppressed,
      deliveryState: deliveryState ?? this.deliveryState,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'notification_key': notificationKey,
      'package_name': packageName,
      'title': title,
      'text': text,
      'post_time': postTime,
      'received_at': receivedAt.millisecondsSinceEpoch,
      'was_emergency_breakthrough': wasEmergencyBreakthrough ? 1 : 0,
      'decision_reason': decisionReason,
      'is_read': isRead ? 1 : 0,
      'is_held_suppressed': isHeldSuppressed ? 1 : 0,
      'delivery_state': deliveryState.toJson(),
      'delivered_at': deliveredAt?.millisecondsSinceEpoch,
    };
  }

  factory StoredNotification.fromMap(Map<String, dynamic> map) {
    return StoredNotification(
      id: map['id'] as int?,
      notificationKey: map['notification_key'] as String,
      packageName: map['package_name'] as String,
      title: map['title'] as String,
      text: map['text'] as String,
      postTime: map['post_time'] as int,
      receivedAt: DateTime.fromMillisecondsSinceEpoch(
        map['received_at'] as int,
      ),
      wasEmergencyBreakthrough:
          (map['was_emergency_breakthrough'] as int? ?? 0) == 1,
      decisionReason: map['decision_reason'] as String? ?? '',
      isRead: (map['is_read'] as int? ?? 0) == 1,
      isHeldSuppressed: (map['is_held_suppressed'] as int? ?? 0) == 1,
      deliveryState: InboxDeliveryState.fromJson(
        map['delivery_state'] as String? ?? InboxDeliveryState.held.name,
      ),
      deliveredAt: map['delivered_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['delivered_at'] as int),
    );
  }
}
