import 'package:flutter_test/flutter_test.dart';
import 'package:prio/utils/time_window_weekdays.dart';

void main() {
  test('mergeWeekdaySelection adds selected weekday when missing', () {
    expect(
      mergeWeekdaySelection(weekdays: [1, 2, 3], selectedWeekday: 4),
      [1, 2, 3, 4],
    );
  });

  test('mergeWeekdaySelection keeps list when weekday already present', () {
    expect(
      mergeWeekdaySelection(weekdays: [2, 4], selectedWeekday: 2),
      [2, 4],
    );
  });
}
