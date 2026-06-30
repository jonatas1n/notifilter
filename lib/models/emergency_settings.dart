class EmergencySettings {
  const EmergencySettings({
    required this.thresholdCount,
    required this.windowMinutes,
  });

  final int thresholdCount;
  final int windowMinutes;

  static const EmergencySettings defaults = EmergencySettings(
    thresholdCount: 3,
    windowMinutes: 5,
  );

  EmergencySettings copyWith({
    int? thresholdCount,
    int? windowMinutes,
  }) {
    return EmergencySettings(
      thresholdCount: thresholdCount ?? this.thresholdCount,
      windowMinutes: windowMinutes ?? this.windowMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thresholdCount': thresholdCount,
      'windowMinutes': windowMinutes,
    };
  }

  factory EmergencySettings.fromJson(Map<String, dynamic> json) {
    return EmergencySettings(
      thresholdCount: json['thresholdCount'] as int? ?? defaults.thresholdCount,
      windowMinutes: json['windowMinutes'] as int? ?? defaults.windowMinutes,
    );
  }
}
