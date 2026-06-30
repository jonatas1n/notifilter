import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/serene_focus_spacing.dart';
import '../providers/app_providers.dart';
import '../widgets/notifilter_logo.dart';
import '../widgets/serene/serene_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
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

    ref.read(notificationAccessProvider.notifier).refresh();
  }

  Future<void> _completeOnboarding() async {
    final settings = await ref.read(appSettingsProvider.future);
    await ref.read(appSettingsProvider.notifier).saveSettings(
          settings.copyWith(onboardingCompleted: true),
        );
  }

  @override
  Widget build(BuildContext context) {
    final accessAsync = ref.watch(notificationAccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const NotifilterLogo(size: 32, showLabel: true),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: NotifilterLogo(size: 88)),
            const SizedBox(height: SereneFocusSpacing.lg),
            Text(
              'Acesso às notificações',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: SereneFocusSpacing.sm),
            Text(
              'O Notifilter precisa de permissão de Notification Listener para '
              'filtrar e organizar alertas. Os dados ficam no dispositivo.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: SereneFocusSpacing.lg),
            SereneCard(
              child: accessAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Erro: $error'),
                data: (granted) => Row(
                  children: [
                    Icon(
                      granted ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: granted
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : Colors.orange,
                    ),
                    const SizedBox(width: SereneFocusSpacing.sm),
                    Expanded(
                      child: Text(
                        granted
                            ? 'Acesso concedido'
                            : 'Acesso ainda não concedido',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                ref.read(notificationAccessProvider.notifier).openSettings();
              },
              child: const Text('Abrir definições de acesso'),
            ),
            const SizedBox(height: SereneFocusSpacing.sm),
            FilledButton.tonal(
              onPressed: _completeOnboarding,
              child: const Text('Continuar para o app'),
            ),
          ],
        ),
      ),
    );
  }
}
