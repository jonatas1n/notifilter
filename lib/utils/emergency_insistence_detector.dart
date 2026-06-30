import '../models/emergency_settings.dart';
import '../models/incoming_notification.dart';

class EmergencyInsistenceEvent {
  const EmergencyInsistenceEvent({
    required this.sourceIdentifier,
    required this.postTime,
  });

  final String sourceIdentifier;
  final int postTime;
}

bool isEmergencyInsistence({
  required IncomingNotification notification,
  required List<EmergencyInsistenceEvent> recentEvents,
  required EmergencySettings settings,
}) {
  if (settings.thresholdCount <= 1) {
    return true;
  }

  final windowStart =
      notification.postTime - (settings.windowMinutes * 60 * 1000);
  final matchingCount = recentEvents
      .where(
        (event) =>
            event.sourceIdentifier == notification.sourceIdentifier &&
            event.postTime >= windowStart &&
            event.postTime <= notification.postTime,
      )
      .length;

  return matchingCount + 1 >= settings.thresholdCount;
}

List<EmergencyInsistenceEvent> appendInsistenceEvent({
  required List<EmergencyInsistenceEvent> recentEvents,
  required IncomingNotification notification,
  required EmergencySettings settings,
}) {
  final updatedEvents = List<EmergencyInsistenceEvent>.from(recentEvents)
    ..add(
      EmergencyInsistenceEvent(
        sourceIdentifier: notification.sourceIdentifier,
        postTime: notification.postTime,
      ),
    );

  final cutoff =
      notification.postTime - (settings.windowMinutes * 60 * 1000 * 2);
  updatedEvents.removeWhere((event) => event.postTime < cutoff);
  return updatedEvents;
}
