import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact_importance_level.dart';
import '../utils/contact_importance_policy.dart';

class ContactImportanceRepository {
  ContactImportanceRepository(this._preferences);

  final SharedPreferences _preferences;
  static const String _levelsKey = 'contact_importance_levels';
  static const String _hideUntilKey = 'contact_hide_until_epoch_ms';

  Map<String, ContactImportanceLevel> loadAll() {
    final raw = _preferences.getString(_levelsKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        ContactImportanceLevel.fromJson(value as String),
      ),
    );
  }

  Map<String, DateTime> loadHideUntilByGroupKey() {
    final raw = _preferences.getString(_hideUntilKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        DateTime.fromMillisecondsSinceEpoch(value as int),
      ),
    );
  }

  DateTime? hideUntilForGroup(String groupKey) {
    return loadHideUntilByGroupKey()[groupKey];
  }

  ContactImportanceLevel levelForGroup(String groupKey) {
    return loadAll()[groupKey] ?? ContactImportanceLevel.normal;
  }

  Future<void> saveLevel(String groupKey, ContactImportanceLevel level) async {
    final current = loadAll();
    current[groupKey] = level;
    await _persistLevels(current);

    if (level == ContactImportanceLevel.hideTemporarily) {
      await _setHideUntil(
        groupKey,
        DateTime.now().add(contactHideTemporaryDuration),
      );
      return;
    }

    await _clearHideUntil(groupKey);
  }

  Future<void> revertExpiredHideToNormal({
    required String groupKey,
    required DateTime evaluationTime,
  }) async {
    final level = levelForGroup(groupKey);
    final hideUntil = hideUntilForGroup(groupKey);

    if (!hasHideTemporarilyExpired(
      level: level,
      evaluationTime: evaluationTime,
      hideUntil: hideUntil,
    )) {
      return;
    }

    final current = loadAll();
    current[groupKey] = ContactImportanceLevel.normal;
    await _persistLevels(current);
    await _clearHideUntil(groupKey);
  }

  Future<void> _setHideUntil(String groupKey, DateTime until) async {
    final current = loadHideUntilByGroupKey();
    current[groupKey] = until;
    await _persistHideUntil(current);
  }

  Future<void> _clearHideUntil(String groupKey) async {
    final current = loadHideUntilByGroupKey();
    current.remove(groupKey);
    await _persistHideUntil(current);
  }

  Future<void> _persistLevels(Map<String, ContactImportanceLevel> levels) async {
    final encoded = jsonEncode(
      levels.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _preferences.setString(_levelsKey, encoded);
  }

  Future<void> _persistHideUntil(Map<String, DateTime> hideUntil) async {
    final encoded = jsonEncode(
      hideUntil.map(
        (key, value) => MapEntry(key, value.millisecondsSinceEpoch),
      ),
    );
    await _preferences.setString(_hideUntilKey, encoded);
  }
}
