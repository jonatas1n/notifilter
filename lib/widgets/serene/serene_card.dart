import 'package:flutter/material.dart';

import '../../core/theme/serene_focus_colors.dart';
import '../../core/theme/serene_focus_spacing.dart';

class SereneCard extends StatelessWidget {
  const SereneCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SereneFocusSpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: SereneFocusColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SereneFocusSpacing.cardRadius),
        border: Border.all(color: SereneFocusColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: SereneFocusColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SereneFocusSpacing.cardRadius),
        child: card,
      ),
    );
  }
}
