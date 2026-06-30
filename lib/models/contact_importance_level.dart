enum ContactImportanceLevel {
  highImportance,
  normal,
  reduceNoise,
  hideTemporarily;

  String get label {
    switch (this) {
      case ContactImportanceLevel.highImportance:
        return 'Alta Importância';
      case ContactImportanceLevel.normal:
        return 'Normal';
      case ContactImportanceLevel.reduceNoise:
        return 'Reduzir Ruído';
      case ContactImportanceLevel.hideTemporarily:
        return 'Ocultar Temporariamente';
    }
  }

  String toJson() => name;

  static ContactImportanceLevel fromJson(String value) {
    return ContactImportanceLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => ContactImportanceLevel.normal,
    );
  }
}
