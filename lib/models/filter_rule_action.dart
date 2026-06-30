enum FilterRuleAction {
  allow,
  block;

  String toJson() => name;

  static FilterRuleAction fromJson(String value) {
    return FilterRuleAction.values.firstWhere(
      (action) => action.name == value,
      orElse: () => FilterRuleAction.block,
    );
  }
}
