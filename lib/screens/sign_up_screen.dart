import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/serene_focus_spacing.dart';
import '../providers/app_providers.dart';
import '../widgets/prio_logo.dart';
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PrioLogo(size: 72),
            const SizedBox(height: SereneFocusSpacing.lg),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _submitStub,
              child: const Text('Create account'),
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
