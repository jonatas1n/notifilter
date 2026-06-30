import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact_importance_level.dart';
import '../models/app_settings.dart';
import '../models/emergency_settings.dart';
import '../models/filter_rule.dart';
import '../models/stored_notification.dart';
import '../models/time_window.dart';
import '../repositories/contact_importance_repository.dart';
import '../repositories/notification_inbox_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/notification_bridge_service.dart';
import '../services/digest_delivery_service.dart';
import '../services/notification_orchestrator_service.dart';
import '../models/notification_inbox_group.dart';
import '../utils/notification_grouper.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return SettingsRepository(preferences);
});

final inboxRepositoryProvider =
    FutureProvider<NotificationInboxRepository>((ref) async {
  return NotificationInboxRepository.create();
});

final notificationBridgeServiceProvider = Provider<NotificationBridgeService>(
  (ref) => NotificationBridgeService(),
);

final notificationOrchestratorProvider =
    FutureProvider<NotificationOrchestratorService>((ref) async {
  final settingsRepository = await ref.watch(settingsRepositoryProvider.future);
  final inboxRepository = await ref.watch(inboxRepositoryProvider.future);
  final contactRepository =
      await ref.watch(contactImportanceRepositoryProvider.future);
  final bridge = ref.watch(notificationBridgeServiceProvider);

  final digestDelivery = DigestDeliveryService(
    settingsRepository: settingsRepository,
    inboxRepository: inboxRepository,
  );

  final orchestrator = NotificationOrchestratorService(
    bridgeService: bridge,
    settingsRepository: settingsRepository,
    inboxRepository: inboxRepository,
    contactImportanceRepository: contactRepository,
    digestDeliveryService: digestDelivery,
  );

  ref.onDispose(orchestrator.dispose);

  await orchestrator.startProcessing();
  return orchestrator;
});

class AppBootstrapNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    await ref.watch(notificationOrchestratorProvider.future);
  }
}

final appBootstrapProvider =
    AsyncNotifierProvider<AppBootstrapNotifier, void>(
  AppBootstrapNotifier.new,
);

class NotificationAccessNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final bridge = ref.watch(notificationBridgeServiceProvider);
    return bridge.isNotificationAccessGranted();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final bridge = ref.read(notificationBridgeServiceProvider);
      return bridge.isNotificationAccessGranted();
    });
  }

  Future<void> openSettings() async {
    final bridge = ref.read(notificationBridgeServiceProvider);
    await bridge.openNotificationAccessSettings();
    await refresh();
  }
}

final notificationAccessProvider =
    AsyncNotifierProvider<NotificationAccessNotifier, bool>(
  NotificationAccessNotifier.new,
);

class InboxNotifier extends AsyncNotifier<List<StoredNotification>> {
  @override
  Future<List<StoredNotification>> build() async {
    final repository = await ref.watch(inboxRepositoryProvider.future);
    return repository.fetchAll();
  }

  Future<void> refreshInbox() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(inboxRepositoryProvider.future);
      return repository.fetchAll();
    });
  }

  Future<void> markAsRead(int id) async {
    final repository = await ref.read(inboxRepositoryProvider.future);
    await repository.markAsRead(id);
    await refreshInbox();
  }
}

final inboxProvider = AsyncNotifierProvider<InboxNotifier, List<StoredNotification>>(
  InboxNotifier.new,
);

class FilterRulesNotifier extends AsyncNotifier<List<FilterRule>> {
  @override
  Future<List<FilterRule>> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.loadFilterRules();
  }

  Future<void> saveRules(List<FilterRule> rules) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.saveFilterRules(rules);
    ref.invalidateSelf();
  }
}

final filterRulesProvider =
    AsyncNotifierProvider<FilterRulesNotifier, List<FilterRule>>(
  FilterRulesNotifier.new,
);

class QuietSchedulesNotifier extends AsyncNotifier<List<TimeWindow>> {
  @override
  Future<List<TimeWindow>> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.loadQuietSchedules();
  }

  Future<void> saveSchedules(List<TimeWindow> schedules) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.saveQuietSchedules(schedules);
    ref.invalidateSelf();
  }
}

final quietSchedulesProvider =
    AsyncNotifierProvider<QuietSchedulesNotifier, List<TimeWindow>>(
  QuietSchedulesNotifier.new,
);

class DigestWindowsNotifier extends AsyncNotifier<List<TimeWindow>> {
  @override
  Future<List<TimeWindow>> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.loadDigestWindows();
  }

  Future<void> saveWindows(List<TimeWindow> windows) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.saveDigestWindows(windows);
    ref.invalidateSelf();
  }
}

final digestWindowsProvider =
    AsyncNotifierProvider<DigestWindowsNotifier, List<TimeWindow>>(
  DigestWindowsNotifier.new,
);

class EmergencySettingsNotifier extends AsyncNotifier<EmergencySettings> {
  @override
  Future<EmergencySettings> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.loadEmergencySettings();
  }

  Future<void> saveSettings(EmergencySettings settings) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.saveEmergencySettings(settings);
    ref.invalidateSelf();
  }
}

final emergencySettingsProvider =
    AsyncNotifierProvider<EmergencySettingsNotifier, EmergencySettings>(
  EmergencySettingsNotifier.new,
);

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.loadAppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.saveAppSettings(settings);
    ref.invalidateSelf();
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

final contactImportanceRepositoryProvider =
    FutureProvider<ContactImportanceRepository>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return ContactImportanceRepository(preferences);
});

class ContactImportanceNotifier
    extends AsyncNotifier<Map<String, ContactImportanceLevel>> {
  @override
  Future<Map<String, ContactImportanceLevel>> build() async {
    final repository =
        await ref.watch(contactImportanceRepositoryProvider.future);
    return repository.loadAll();
  }

  Future<void> setLevel(String groupKey, ContactImportanceLevel level) async {
    final repository =
        await ref.read(contactImportanceRepositoryProvider.future);
    await repository.saveLevel(groupKey, level);
    ref.invalidateSelf();
  }
}

final contactImportanceProvider = AsyncNotifierProvider<
    ContactImportanceNotifier, Map<String, ContactImportanceLevel>>(
  ContactImportanceNotifier.new,
);

final inboxGroupsProvider =
    Provider<AsyncValue<List<NotificationInboxGroup>>>((ref) {
  final inboxAsync = ref.watch(inboxProvider);
  return inboxAsync.whenData(groupStoredNotifications);
});

String formatMinutesAsTime(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

TimeOfDay minutesToTimeOfDay(int minutes) {
  return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
}

int timeOfDayToMinutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}
