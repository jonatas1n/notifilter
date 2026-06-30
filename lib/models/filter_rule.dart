import 'filter_match_type.dart';
import 'filter_rule_action.dart';
import 'predefined_category.dart';

class FilterRule {
  const FilterRule({
    required this.id,
    required this.keyword,
    required this.matchType,
    required this.action,
    this.packageName,
    this.category,
  });

  final String id;
  final String keyword;
  final FilterMatchType matchType;
  final FilterRuleAction action;
  final String? packageName;
  final PredefinedCategory? category;

  FilterRule copyWith({
    String? id,
    String? keyword,
    FilterMatchType? matchType,
    FilterRuleAction? action,
    String? packageName,
    PredefinedCategory? category,
    bool clearPackageName = false,
    bool clearCategory = false,
  }) {
    return FilterRule(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      matchType: matchType ?? this.matchType,
      action: action ?? this.action,
      packageName: clearPackageName ? null : (packageName ?? this.packageName),
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'matchType': matchType.toJson(),
      'action': action.toJson(),
      'packageName': packageName,
      'category': category?.name,
    };
  }

  factory FilterRule.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    return FilterRule(
      id: json['id'] as String,
      keyword: json['keyword'] as String,
      matchType: FilterMatchType.fromJson(json['matchType'] as String),
      action: FilterRuleAction.fromJson(json['action'] as String),
      packageName: json['packageName'] as String?,
      category: categoryName == null
          ? null
          : PredefinedCategory.fromName(categoryName),
    );
  }
}
