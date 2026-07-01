import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/theme/serene_focus_colors.dart';

/// Renders the Prio brand mark (a stylised "brightness" sun).
///
/// Use [badge] for hero placements (splash, onboarding header) to wrap the
/// mark in the light rounded-square badge that matches the launcher icon.
class PrioLogo extends StatelessWidget {
  const PrioLogo({
    super.key,
    this.size = 48,
    this.showLabel = false,
    this.badge = false,
    this.color,
    this.badgeDark = false,
  });

  final double size;
  final bool showLabel;
  final bool badge;

  /// When [badge] is true, use the dark backdrop + cyan mark (legacy pairing).
  final bool badgeDark;

  /// Overrides the mark color when [badge] is false.
  final Color? color;

  static const String _assetPath = 'assets/icon/prio_logo.svg';

  @override
  Widget build(BuildContext context) {
    final mark = badge
        ? _buildBadge(context)
        : _buildMark(color ?? _defaultMarkColor, size);

    if (!showLabel) {
      return mark;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.25),
        Text(
          'Prio',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  Color get _defaultMarkColor => SereneFocusColors.brandMark;

  Widget _buildMark(Color markColor, double markSize) {
    return SvgPicture.asset(
      _assetPath,
      width: markSize,
      height: markSize,
      colorFilter: ColorFilter.mode(markColor, BlendMode.srcIn),
      semanticsLabel: 'Prio',
    );
  }

  Widget _buildBadge(BuildContext context) {
    final backdrop = badgeDark
        ? SereneFocusColors.brandBackdropDark
        : SereneFocusColors.brandBackdropLight;
    final markColor = badgeDark
        ? SereneFocusColors.brandMarkOnDark
        : SereneFocusColors.brandMark;
    final borderColor = badgeDark
        ? Colors.transparent
        : Theme.of(context).colorScheme.outlineVariant;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backdrop,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: borderColor == Colors.transparent
            ? null
            : Border.all(color: borderColor, width: 1),
      ),
      alignment: Alignment.center,
      child: _buildMark(markColor, size * 0.62),
    );
  }
}
