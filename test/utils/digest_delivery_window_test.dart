import 'package:flutter_test/flutter_test.dart';

import 'package:notifilter/models/time_window.dart';
import 'package:notifilter/utils/digest_window_evaluator.dart';

void main() {
  group('digest delivery window detection', () {
    const digest = TimeWindow(
      id: '1',
      startMinutes: 22 * 60,
      endMinutes: 7 * 60,
      weekdays: [1, 2, 3, 4, 5, 6, 7],
    );

    test('inside overnight digest window', () {
      final inside = isWithinDigestWindow(
        dateTime: DateTime(2026, 6, 29, 6, 30),
        digestWindows: const [digest],
      );

      expect(inside, isTrue);
    });

    test('outside digest window when condensed would hold', () {
      final outside = DateTime(2026, 6, 29, 12, 0);
      expect(
        isWithinDigestWindow(dateTime: outside, digestWindows: const [digest]),
        isFalse,
      );
      expect(
        shouldHoldForCondensedInbox(
          condensedInboxEnabled: true,
          dateTime: outside,
          digestWindows: const [digest],
        ),
        isTrue,
      );
    });
  });
}
