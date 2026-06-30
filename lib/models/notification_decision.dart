enum NotificationDecisionType {
  show,
  hold,
}

class NotificationDecision {
  const NotificationDecision({
    required this.type,
    required this.reason,
    this.isEmergencyBreakthrough = false,
  });

  final NotificationDecisionType type;
  final String reason;
  final bool isEmergencyBreakthrough;

  bool get shouldSuppress => type == NotificationDecisionType.hold;
}
