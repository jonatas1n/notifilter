import 'package:flutter/material.dart';

import '../../core/theme/serene_focus_colors.dart';
import '../../core/theme/serene_focus_spacing.dart';
import 'serene_card.dart';

class SereneStatCard extends StatelessWidget {
  const SereneStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SereneCard(
        padding: const EdgeInsets.all(SereneFocusSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: SereneFocusColors.primary, size: 20),
            const SizedBox(height: SereneFocusSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
