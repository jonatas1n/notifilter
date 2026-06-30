enum InboxDeliveryState {
  held,
  delivered,
  shownLive;

  String toJson() => name;

  static InboxDeliveryState fromJson(String value) {
    return InboxDeliveryState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => InboxDeliveryState.held,
    );
  }
}
