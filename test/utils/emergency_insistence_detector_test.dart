import 'package:flutter_test/flutter_test.dart';

import 'package:notifilter/models/emergency_settings.dart';
import 'package:notifilter/models/incoming_notification.dart';
import 'package:notifilter/utils/emergency_insistence_detector.dart';

void main() {
  group('emergency_insistence_detector', () {
    const settings = EmergencySettings(thresholdCount: 3, windowMinutes: 5);

    test('detects insistence after repeated source events', () {
      const notification = IncomingNotification(
        key: '3',
        packageName: 'com.chat',
        title: 'Alex',
        text: 'ping',
        postTime: 300000,
      );

      const recentEvents = [
        EmergencyInsistenceEvent(
          sourceIdentifier: 'com.chat::Alex',
          postTime: 120000,
        ),
        EmergencyInsistenceEvent(
          sourceIdentifier: 'com.chat::Alex',
          postTime: 240000,
        ),
      ];

      expect(
        isEmergencyInsistence(
          notification: notification,
          recentEvents: recentEvents,
          settings: settings,
        ),
        isTrue,
      );
    });

    test('does not trigger below threshold', () {
      const notification = IncomingNotification(
        key: '2',
        packageName: 'com.chat',
        title: 'Alex',
        text: 'ping',
        postTime: 300000,
      );

      const recentEvents = [
        EmergencyInsistenceEvent(
          sourceIdentifier: 'com.chat::Alex',
          postTime: 120000,
        ),
      ];

      expect(
        isEmergencyInsistence(
          notification: notification,
          recentEvents: recentEvents,
          settings: settings,
        ),
        isFalse,
      );
    });
  });
}
