import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/serene_focus_theme.dart';
import 'providers/app_providers.dart';
import 'screens/home_shell_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'utils/app_flow_phase.dart';

class NotifilterApp extends ConsumerStatefulWidget {
  const NotifilterApp({super.key});

  @override
  ConsumerState<NotifilterApp> createState() => _NotifilterAppState();
}

class _NotifilterAppState extends ConsumerState<NotifilterApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    ref.read(notificationOrchestratorProvider.future).then((orchestrator) {
      return orchestrator.checkDigestWindows();
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrint('Digest check on resume failed: $error');
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appBootstrapProvider);

    final settingsAsync = ref.watch(appSettingsProvider);

    return settingsAsync.when(
      loading: () => MaterialApp(
        theme: SereneFocusTheme.light(),
        home: const _SplashScreen(),
      ),
      error: (error, _) => MaterialApp(
        theme: SereneFocusTheme.light(),
        home: _ErrorScreen(message: error.toString()),
      ),
      data: (settings) {
        final phase = appFlowPhaseForSettings(settings);
        final home = switch (phase) {
          AppFlowPhase.welcome => const WelcomeScreen(),
          AppFlowPhase.onboarding => const OnboardingScreen(),
          AppFlowPhase.main => const HomeShellScreen(),
        };

        return MaterialApp(
          key: ValueKey(appFlowPhaseKey(phase)),
          title: 'Notifilter',
          theme: SereneFocusTheme.light(),
          home: home,
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }
}
