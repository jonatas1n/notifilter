import '../models/filter_match_type.dart';
import '../models/filter_rule.dart';
import '../models/filter_rule_action.dart';
import '../models/incoming_notification.dart';
import '../models/predefined_category.dart';

bool notificationMatchesRule(
  IncomingNotification notification,
  FilterRule rule,
) {
  if (!_packageMatches(notification.packageName, rule.packageName)) {
    return false;
  }

  final keyword = rule.keyword.trim();
  if (keyword.isEmpty && rule.category == null) {
    return false;
  }

  if (rule.category != null) {
    return _matchesCategory(notification, rule.category!);
  }

  return _matchesKeyword(
    notification.combinedBody,
    notification.title,
    keyword,
    rule.matchType,
  );
}

bool _packageMatches(String packageName, String? rulePackage) {
  if (rulePackage == null || rulePackage.isEmpty) {
    return true;
  }
  return packageName == rulePackage;
}

bool _matchesCategory(
  IncomingNotification notification,
  PredefinedCategory category,
) {
  for (final keyword in category.defaultKeywords) {
    if (_matchesKeyword(
      notification.combinedBody,
      notification.title,
      keyword,
      FilterMatchType.contains,
    )) {
      return true;
    }
  }
  return false;
}

bool _matchesKeyword(
  String body,
  String title,
  String keyword,
  FilterMatchType matchType,
) {
  final normalizedKeyword = keyword.toLowerCase();
  final haystack = '${title.toLowerCase()} ${body.toLowerCase()}';

  if (matchType == FilterMatchType.exact) {
    return haystack.trim() == normalizedKeyword ||
        title.toLowerCase() == normalizedKeyword ||
        body.toLowerCase() == normalizedKeyword;
  }

  return haystack.contains(normalizedKeyword);
}

FilterRuleAction? evaluateKeywordRules({
  required IncomingNotification notification,
  required List<FilterRule> rules,
}) {
  FilterRuleAction? matchedAllow;
  FilterRuleAction? matchedBlock;

  for (final rule in rules) {
    if (!notificationMatchesRule(notification, rule)) {
      continue;
    }

    if (rule.action == FilterRuleAction.allow) {
      matchedAllow = FilterRuleAction.allow;
      break;
    }

    matchedBlock = FilterRuleAction.block;
  }

  if (matchedAllow == FilterRuleAction.allow) {
    return FilterRuleAction.allow;
  }

  return matchedBlock;
}
