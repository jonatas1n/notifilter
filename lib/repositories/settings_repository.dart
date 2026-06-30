import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/emergency_settings.dart';
import '../models/filter_match_type.dart';
import '../models/filter_rule.dart';
import '../models/filter_rule_action.dart';
import '../models/predefined_category.dart';
import '../models/time_window.dart';

class SettingsRepository {
  SettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  static const String _rulesKey = 'filter_rules';
  static const String _quietSchedulesKey = 'quiet_schedules';
  static const String _digestWindowsKey = 'digest_windows';
  static const String _emergencyKey = 'emergency_settings';
  static const String _appSettingsKey = 'app_settings';

  List<FilterRule> loadFilterRules() {
    final raw = _preferences.getString(_rulesKey);
    if (raw == null || raw.isEmpty) {
      return _defaultRules();
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (entry) =>
              FilterRule.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  Future<void> saveFilterRules(List<FilterRule> rules) async {
    final encoded = jsonEncode(rules.map((rule) => rule.toJson()).toList());
    await _preferences.setString(_rulesKey, encoded);
  }

  List<TimeWindow> loadQuietSchedules() {
    return _loadTimeWindows(_quietSchedulesKey);
  }

  Future<void> saveQuietSchedules(List<TimeWindow> windows) async {
    await _saveTimeWindows(_quietSchedulesKey, windows);
  }

  List<TimeWindow> loadDigestWindows() {
    return _loadTimeWindows(_digestWindowsKey);
  }

  Future<void> saveDigestWindows(List<TimeWindow> windows) async {
    await _saveTimeWindows(_digestWindowsKey, windows);
  }

  EmergencySettings loadEmergencySettings() {
    final raw = _preferences.getString(_emergencyKey);
    if (raw == null || raw.isEmpty) {
      return EmergencySettings.defaults;
    }
    return EmergencySettings.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> saveEmergencySettings(EmergencySettings settings) async {
    await _preferences.setString(_emergencyKey, jsonEncode(settings.toJson()));
  }

  AppSettings loadAppSettings() {
    final raw = _preferences.getString(_appSettingsKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults;
    }
    return AppSettings.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await _preferences.setString(_appSettingsKey, jsonEncode(settings.toJson()));
  }

  List<TimeWindow> _loadTimeWindows(String key) {
    final raw = _preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (entry) =>
              TimeWindow.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  Future<void> _saveTimeWindows(String key, List<TimeWindow> windows) async {
    final encoded =
        jsonEncode(windows.map((window) => window.toJson()).toList());
    await _preferences.setString(key, encoded);
  }

  List<FilterRule> _defaultRules() {
    return [
      FilterRule(
        id: 'default-promotions-block',
        keyword: 'sale',
        matchType: FilterMatchType.contains,
        action: FilterRuleAction.block,
        category: PredefinedCategory.promotions,
      ),
    ];
  }
}
