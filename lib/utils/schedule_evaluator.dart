import '../models/time_window.dart';

bool isDateTimeWithinTimeWindow({
  required DateTime dateTime,
  required TimeWindow window,
}) {
  if (!window.weekdays.contains(dateTime.weekday)) {
    return false;
  }

  final currentMinutes = dateTime.hour * 60 + dateTime.minute;
  return _isMinuteWithinWindow(
    currentMinutes,
    window.startMinutes,
    window.endMinutes,
  );
}

bool isDateTimeWithinAnyTimeWindow({
  required DateTime dateTime,
  required List<TimeWindow> windows,
}) {
  for (final window in windows) {
    if (isDateTimeWithinTimeWindow(dateTime: dateTime, window: window)) {
      return true;
    }
  }
  return false;
}

bool _isMinuteWithinWindow(
  int currentMinutes,
  int startMinutes,
  int endMinutes,
) {
  if (startMinutes == endMinutes) {
    return false;
  }

  if (startMinutes < endMinutes) {
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  return currentMinutes >= startMinutes || currentMinutes < endMinutes;
}
