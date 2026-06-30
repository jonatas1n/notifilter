import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/serene_focus_spacing.dart';
import '../providers/app_providers.dart';
import '../widgets/notifilter_logo.dart';
import 'premium_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return ListView(
      padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
      children: [
        const Center(child: NotifilterLogo(size: 64)),
        const SizedBox(height: SereneFocusSpacing.lg),
        settingsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (settings) {
            if (settings.isGuestMode) {
              return ListTile(
                title: const Text('Modo convidado'),
                subtitle: const Text('Sem conta — dados apenas neste dispositivo'),
                trailing: const Icon(Icons.person_outline),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        _SettingsGroup(
          title: 'Account',
          tiles: [
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
              ),
            ),
          ],
        ),
        _SettingsGroup(
          title: 'Notifications',
          tiles: [
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Notification access'),
              onTap: () {
                ref.read(notificationAccessProvider.notifier).openSettings();
              },
            ),
          ],
        ),
        _SettingsGroup(
          title: 'Appearance',
          tiles: const [
            ListTile(
              leading: Icon(Icons.palette_outlined),
              title: Text('Serene Focus theme'),
              subtitle: Text('Tema claro ativo'),
            ),
          ],
        ),
        _SettingsGroup(
          title: 'Premium',
          tiles: [
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Unlock Absolute Focus'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PremiumScreen()),
              ),
            ),
          ],
        ),
        _SettingsGroup(
          title: 'Help & Support',
          tiles: const [
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Documentation'),
              subtitle: Text('Ver README do projeto'),
            ),
          ],
        ),
        _SettingsGroup(
          title: 'About',
          tiles: const [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Notifilter'),
              subtitle: Text('Versão 1.0.0 — plano gratuito'),
            ),
          ],
        ),
        const SizedBox(height: SereneFocusSpacing.lg),
        OutlinedButton(
          onPressed: () async {
            final settings = await ref.read(appSettingsProvider.future);
            await ref.read(appSettingsProvider.notifier).saveSettings(
                  settings.copyWith(
                    welcomeCompleted: false,
                    onboardingCompleted: false,
                  ),
                );
          },
          child: const Text('Log Out'),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: SereneFocusSpacing.md,
            bottom: SereneFocusSpacing.xs,
          ),
          child: Text(title, style: Theme.of(context).textTheme.labelLarge),
        ),
        Card(
          child: Column(children: tiles),
        ),
      ],
    );
  }
}
