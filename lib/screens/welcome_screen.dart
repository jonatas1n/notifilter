import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/serene_focus_spacing.dart';
import '../providers/app_providers.dart';
import '../widgets/notifilter_logo.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const NotifilterLogo(size: 96),
              const SizedBox(height: SereneFocusSpacing.lg),
              Text(
                'Notifilter',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                'Digital Zen para as suas notificações',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _continueAsGuest(context, ref),
                child: const Text('Continuar como convidado'),
              ),
              const SizedBox(height: SereneFocusSpacing.sm),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Sign in'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
                  );
                },
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continueAsGuest(BuildContext context, WidgetRef ref) async {
    final settings = await ref.read(appSettingsProvider.future);
    await ref.read(appSettingsProvider.notifier).saveSettings(
          settings.copyWith(welcomeCompleted: true, isGuestMode: true),
        );
  }
}
