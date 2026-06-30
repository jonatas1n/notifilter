import '../models/contact_importance_level.dart';
import '../models/notification_decision.dart';

/// Default duration for [ContactImportanceLevel.hideTemporarily].
const Duration contactHideTemporaryDuration = Duration(hours: 24);

bool isHideTemporarilyActive({
  required ContactImportanceLevel level,
  required DateTime evaluationTime,
  required DateTime? hideUntil,
}) {
  if (level != ContactImportanceLevel.hideTemporarily) {
    return false;
  }

  if (hideUntil == null) {
    return true;
  }

  return evaluationTime.isBefore(hideUntil);
}

bool hasHideTemporarilyExpired({
  required ContactImportanceLevel level,
  required DateTime evaluationTime,
  required DateTime? hideUntil,
}) {
  if (level != ContactImportanceLevel.hideTemporarily) {
    return false;
  }

  if (hideUntil == null) {
    return false;
  }

  return !evaluationTime.isBefore(hideUntil);
}

bool isSilenceWindowActive({
  required bool inQuietSchedule,
  required bool inCondensedHold,
}) {
  return inQuietSchedule || inCondensedHold;
}

bool isDirectCommunicationCategory(String? category) {
  if (category == null || category.isEmpty) {
    return false;
  }

  const directCategories = {
    'msg',
    'call',
    'alarm',
    'navigation',
    'transport',
  };

  return directCategories.contains(category.toLowerCase());
}

bool bodyContainsMentionSignal(String body) {
  final normalized = body.toLowerCase();
  return normalized.contains('@') || normalized.contains('mentioned you');
}

bool shouldReduceNoiseHold({
  required bool isSilenceActive,
  required String? category,
  required String body,
}) {
  if (!isSilenceActive) {
    return false;
  }

  if (isDirectCommunicationCategory(category)) {
    return false;
  }

  if (bodyContainsMentionSignal(body)) {
    return false;
  }

  return true;
}

/// Contact-importance overrides before schedule rules (except emergency, handled earlier).
NotificationDecision? decisionFromContactImportance({
  required ContactImportanceLevel level,
  required DateTime evaluationTime,
  required DateTime? hideUntil,
  required bool inQuietSchedule,
  required bool inCondensedHold,
  required String? category,
  required String body,
}) {
  if (isHideTemporarilyActive(
    level: level,
    evaluationTime: evaluationTime,
    hideUntil: hideUntil,
  )) {
    return const NotificationDecision(
      type: NotificationDecisionType.hold,
      reason: 'Ocultar temporariamente',
    );
  }

  if (level == ContactImportanceLevel.highImportance) {
    return const NotificationDecision(
      type: NotificationDecisionType.show,
      reason: 'Alta importância do contacto',
    );
  }

  if (level != ContactImportanceLevel.reduceNoise) {
    return null;
  }

  final silenceActive = isSilenceWindowActive(
    inQuietSchedule: inQuietSchedule,
    inCondensedHold: inCondensedHold,
  );

  if (!shouldReduceNoiseHold(
    isSilenceActive: silenceActive,
    category: category,
    body: body,
  )) {
    return null;
  }

  return const NotificationDecision(
    type: NotificationDecisionType.hold,
    reason: 'Reduzir ruído durante silêncio/condensado',
  );
}
