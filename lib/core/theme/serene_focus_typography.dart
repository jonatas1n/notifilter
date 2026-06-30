import 'package:flutter/material.dart';

import 'serene_focus_colors.dart';

/// Serene Focus typography scale using bundled [Outfit] (see pubspec fonts).
abstract final class SereneFocusTypography {
  static const String fontFamily = 'Outfit';

  static TextStyle outfit({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme() {
    return TextTheme(
      headlineLarge: outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.24,
        color: SereneFocusColors.onSurface,
      ),
      headlineMedium: outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: SereneFocusColors.onSurface,
      ),
      titleMedium: outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        color: SereneFocusColors.onSurface,
      ),
      bodyLarge: outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: SereneFocusColors.onSurface,
      ),
      bodyMedium: outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: SereneFocusColors.onSurface,
      ),
      bodySmall: outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: SereneFocusColors.onSurfaceVariant,
      ),
      labelLarge: outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.6,
        color: SereneFocusColors.primary,
      ),
    );
  }
}
