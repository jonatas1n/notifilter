class TimeWindow {
  const TimeWindow({
    required this.id,
    required this.startMinutes,
    required this.endMinutes,
    required this.weekdays,
  });

  final String id;
  final int startMinutes;
  final int endMinutes;
  final List<int> weekdays;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'weekdays': weekdays,
    };
  }

  factory TimeWindow.fromJson(Map<String, dynamic> json) {
    return TimeWindow(
      id: json['id'] as String,
      startMinutes: json['startMinutes'] as int,
      endMinutes: json['endMinutes'] as int,
      weekdays: (json['weekdays'] as List<dynamic>)
          .map((day) => day as int)
          .toList(),
    );
  }
}
