class IncomingNotificationRemoteInput {
  const IncomingNotificationRemoteInput({
    required this.resultKey,
    required this.label,
  });

  final String resultKey;
  final String label;

  factory IncomingNotificationRemoteInput.fromMap(Map<String, dynamic> map) {
    return IncomingNotificationRemoteInput(
      resultKey: map['resultKey'] as String? ?? '',
      label: map['label'] as String? ?? '',
    );
  }
}

class IncomingNotificationAction {
  const IncomingNotificationAction({
    required this.index,
    required this.title,
    required this.remoteInputs,
  });

  final int index;
  final String title;
  final List<IncomingNotificationRemoteInput> remoteInputs;

  bool get supportsReply => remoteInputs.isNotEmpty;

  factory IncomingNotificationAction.fromMap(Map<String, dynamic> map) {
    final remoteInputMaps = map['remoteInputs'] as List<dynamic>? ?? [];
    return IncomingNotificationAction(
      index: map['index'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      remoteInputs: remoteInputMaps
          .whereType<Map>()
          .map(
            (entry) => IncomingNotificationRemoteInput.fromMap(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList(),
    );
  }
}

class IncomingNotification {
  const IncomingNotification({
    required this.key,
    required this.packageName,
    required this.title,
    required this.text,
    required this.postTime,
    this.bigText,
    this.channelId,
    this.category,
    this.actions = const [],
    this.eventType = 'posted',
  });

  final String key;
  final String packageName;
  final String title;
  final String text;
  final String? bigText;
  final int postTime;
  final String? channelId;
  final String? category;
  final List<IncomingNotificationAction> actions;
  final String eventType;

  String get combinedBody => bigText?.isNotEmpty == true ? bigText! : text;

  String get sourceIdentifier => '$packageName::$title';

  factory IncomingNotification.fromEventPayload(Map<String, dynamic> json) {
    final actionMaps = json['actions'] as List<dynamic>? ?? [];
    return IncomingNotification(
      key: json['key'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      bigText: json['bigText'] as String?,
      postTime: json['postTime'] as int? ?? 0,
      channelId: json['channelId'] as String?,
      category: json['category'] as String?,
      eventType: json['eventType'] as String? ?? 'posted',
      actions: actionMaps
          .whereType<Map>()
          .map(
            (entry) => IncomingNotificationAction.fromMap(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList(),
    );
  }
}
