import 'package:flutter_test/flutter_test.dart';

import 'package:notifilter/models/time_window.dart';
import 'package:notifilter/utils/digest_window_evaluator.dart';

void main() {
  group('digest_window_evaluator', () {
    test('holds outside digest when condensed mode enabled', () {
      const digest = TimeWindow(
        id: '1',
        startMinutes: 12 * 60,
        endMinutes: 13 * 60,
        weekdays: [1, 2, 3, 4, 5, 6, 7],
      );

      final outside = DateTime(2026, 6, 29, 9, 0);
      expect(
        shouldHoldForCondensedInbox(
          condensedInboxEnabled: true,
          dateTime: outside,
          digestWindows: const [digest],
        ),
        isTrue,
      );
    });

    test('does not hold during digest window', () {
      const digest = TimeWindow(
        id: '1',
        startMinutes: 12 * 60,
        endMinutes: 13 * 60,
        weekdays: [1, 2, 3, 4, 5, 6, 7],
      );

      final inside = DateTime(2026, 6, 29, 12, 15);
      expect(
        shouldHoldForCondensedInbox(
          condensedInboxEnabled: true,
          dateTime: inside,
          digestWindows: const [digest],
        ),
        isFalse,
      );
    });
  });
}
