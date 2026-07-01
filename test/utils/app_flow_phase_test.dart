import 'package:flutter_test/flutter_test.dart';
import 'package:prio/models/app_settings.dart';
import 'package:prio/utils/app_flow_phase.dart';

void main() {
  test('appFlowPhaseForSettings follows welcome then onboarding then main', () {
    const fresh = AppSettings(
      onboardingCompleted: false,
      welcomeCompleted: false,
      condensedInboxEnabled: false,
      contactUnifySuggestionDismissed: false,
      isGuestMode: true,
    );

    expect(appFlowPhaseForSettings(fresh), AppFlowPhase.welcome);

    final afterWelcome = fresh.copyWith(welcomeCompleted: true);
    expect(appFlowPhaseForSettings(afterWelcome), AppFlowPhase.onboarding);

    final afterOnboarding = afterWelcome.copyWith(onboardingCompleted: true);
    expect(appFlowPhaseForSettings(afterOnboarding), AppFlowPhase.main);
  });
}
