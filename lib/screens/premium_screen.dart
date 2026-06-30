import 'package:flutter/material.dart';

import '../core/theme/serene_focus_colors.dart';
import '../core/theme/serene_focus_spacing.dart';
import '../widgets/notifilter_logo.dart';
import '../widgets/serene/serene_card.dart';

/// Premium UI scaffold — funcionalidade não implementada (ver README).
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Premium'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
        children: [
          const Center(child: NotifilterLogo(size: 88)),
          const SizedBox(height: SereneFocusSpacing.lg),
          Text(
            'Unlock Absolute Focus',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: SereneFocusSpacing.sm),
          Text(
            'Filtragem IA e respostas inteligentes — planeado, não incluído na app gratuita.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: SereneFocusSpacing.lg),
          SereneCard(
            child: Column(
              children: const [
                _PremiumFeatureRow(
                  title: 'Contextual AI filtering',
                  subtitle: 'Interpretação semântica além de keywords.',
                ),
                Divider(),
                _PremiumFeatureRow(
                  title: 'Smart auto-replies',
                  subtitle: 'Respostas via RemoteInput no listener nativo.',
                ),
                Divider(),
                _PremiumFeatureRow(
                  title: 'Advanced contact unification',
                  subtitle: 'Um inbox unificado entre apps.',
                ),
              ],
            ),
          ),
          const SizedBox(height: SereneFocusSpacing.lg),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Billing não implementado — ver README Premium.'),
                ),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureRow extends StatelessWidget {
  const _PremiumFeatureRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.check_circle, color: SereneFocusColors.success),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
