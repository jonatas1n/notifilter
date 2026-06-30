import '../models/time_window.dart';
import 'schedule_evaluator.dart';

bool isWithinDigestWindow({
  required DateTime dateTime,
  required List<TimeWindow> digestWindows,
}) {
  if (digestWindows.isEmpty) {
    return false;
  }

  return isDateTimeWithinAnyTimeWindow(
    dateTime: dateTime,
    windows: digestWindows,
  );
}

bool shouldHoldForCondensedInbox({
  required bool condensedInboxEnabled,
  required DateTime dateTime,
  required List<TimeWindow> digestWindows,
}) {
  if (!condensedInboxEnabled) {
    return false;
  }

  return !isWithinDigestWindow(
    dateTime: dateTime,
    digestWindows: digestWindows,
  );
}
