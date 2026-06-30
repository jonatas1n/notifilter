import '../models/app_settings.dart';

enum AppFlowPhase {
  welcome,
  onboarding,
  main,
}

AppFlowPhase appFlowPhaseForSettings(AppSettings settings) {
  if (!settings.welcomeCompleted) {
    return AppFlowPhase.welcome;
  }

  if (!settings.onboardingCompleted) {
    return AppFlowPhase.onboarding;
  }

  return AppFlowPhase.main;
}

String appFlowPhaseKey(AppFlowPhase phase) => phase.name;
