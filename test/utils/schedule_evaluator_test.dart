import 'package:flutter_test/flutter_test.dart';

import 'package:notifilter/models/time_window.dart';
import 'package:notifilter/utils/schedule_evaluator.dart';

void main() {
  group('schedule_evaluator', () {
    test('matches same-day quiet window', () {
      const window = TimeWindow(
        id: '1',
        startMinutes: 22 * 60,
        endMinutes: 23 * 60,
        weekdays: [1, 2, 3, 4, 5],
      );

      final mondayAtTenPm = DateTime(2026, 6, 29, 22, 30);
      expect(
        isDateTimeWithinTimeWindow(dateTime: mondayAtTenPm, window: window),
        isTrue,
      );
    });

    test('matches overnight quiet window after midnight', () {
      const window = TimeWindow(
        id: '1',
        startMinutes: 22 * 60,
        endMinutes: 7 * 60,
        weekdays: [1, 2, 3, 4, 5, 6, 7],
      );

      final earlyMorning = DateTime(2026, 6, 29, 6, 30);
      expect(
        isDateTimeWithinTimeWindow(dateTime: earlyMorning, window: window),
        isTrue,
      );
    });

    test('ignores inactive weekday', () {
      const window = TimeWindow(
        id: '1',
        startMinutes: 9 * 60,
        endMinutes: 17 * 60,
        weekdays: [1],
      );

      final tuesday = DateTime(2026, 6, 30, 10, 0);
      expect(
        isDateTimeWithinTimeWindow(dateTime: tuesday, window: window),
        isFalse,
      );
    });
  });
}
