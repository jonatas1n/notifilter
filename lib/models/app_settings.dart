class AppSettings {
  const AppSettings({
    required this.condensedInboxEnabled,
    required this.onboardingCompleted,
    required this.welcomeCompleted,
    required this.isGuestMode,
    required this.contactUnifySuggestionDismissed,
  });

  final bool condensedInboxEnabled;
  final bool onboardingCompleted;
  final bool welcomeCompleted;
  final bool isGuestMode;
  final bool contactUnifySuggestionDismissed;

  static const AppSettings defaults = AppSettings(
    condensedInboxEnabled: false,
    onboardingCompleted: false,
    welcomeCompleted: false,
    isGuestMode: true,
    contactUnifySuggestionDismissed: false,
  );

  AppSettings copyWith({
    bool? condensedInboxEnabled,
    bool? onboardingCompleted,
    bool? welcomeCompleted,
    bool? isGuestMode,
    bool? contactUnifySuggestionDismissed,
  }) {
    return AppSettings(
      condensedInboxEnabled:
          condensedInboxEnabled ?? this.condensedInboxEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      welcomeCompleted: welcomeCompleted ?? this.welcomeCompleted,
      isGuestMode: isGuestMode ?? this.isGuestMode,
      contactUnifySuggestionDismissed: contactUnifySuggestionDismissed ??
          this.contactUnifySuggestionDismissed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condensedInboxEnabled': condensedInboxEnabled,
      'onboardingCompleted': onboardingCompleted,
      'welcomeCompleted': welcomeCompleted,
      'isGuestMode': isGuestMode,
      'contactUnifySuggestionDismissed': contactUnifySuggestionDismissed,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      condensedInboxEnabled: json['condensedInboxEnabled'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      welcomeCompleted: json['welcomeCompleted'] as bool? ?? false,
      isGuestMode: json['isGuestMode'] as bool? ?? true,
      contactUnifySuggestionDismissed:
          json['contactUnifySuggestionDismissed'] as bool? ?? false,
    );
  }
}
