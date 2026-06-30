import 'package:flutter/material.dart';

import '../../core/theme/serene_focus_colors.dart';
import '../../core/theme/serene_focus_spacing.dart';

class SereneSectionHeader extends StatelessWidget {
  const SereneSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SereneFocusSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: SereneFocusSpacing.xs),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class SereneCapsLabel extends StatelessWidget {
  const SereneCapsLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: SereneFocusColors.primary,
          ),
    );
  }
}
