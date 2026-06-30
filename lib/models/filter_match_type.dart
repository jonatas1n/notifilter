enum FilterMatchType {
  contains,
  exact;

  String toJson() => name;

  static FilterMatchType fromJson(String value) {
    return FilterMatchType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => FilterMatchType.contains,
    );
  }
}
