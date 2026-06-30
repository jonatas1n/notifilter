import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/serene_focus_spacing.dart';
import '../providers/app_providers.dart';
import '../widgets/notifilter_logo.dart';
/// Auth stub — sem backend.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NotifilterLogo(size: 72),
            const SizedBox(height: SereneFocusSpacing.lg),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _submitStub,
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitStub() async {
    final settings = await ref.read(appSettingsProvider.future);
    await ref.read(appSettingsProvider.notifier).saveSettings(
          settings.copyWith(
            welcomeCompleted: true,
            isGuestMode: false,
          ),
        );
  }
}
