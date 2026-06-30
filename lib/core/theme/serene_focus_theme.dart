import 'package:flutter/material.dart';

import 'serene_focus_colors.dart';
import 'serene_focus_spacing.dart';
import 'serene_focus_typography.dart';

abstract final class SereneFocusTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: SereneFocusColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: SereneFocusColors.primary,
      onPrimary: SereneFocusColors.onPrimary,
      primaryContainer: SereneFocusColors.primaryContainer,
      onPrimaryContainer: SereneFocusColors.onPrimaryContainer,
      secondary: SereneFocusColors.secondary,
      onSecondary: SereneFocusColors.onSecondary,
      secondaryContainer: SereneFocusColors.secondaryContainer,
      onSecondaryContainer: SereneFocusColors.onSecondaryContainer,
      tertiary: SereneFocusColors.tertiary,
      tertiaryContainer: SereneFocusColors.tertiaryContainer,
      onTertiaryContainer: SereneFocusColors.onTertiaryContainer,
      surface: SereneFocusColors.surface,
      onSurface: SereneFocusColors.onSurface,
      onSurfaceVariant: SereneFocusColors.onSurfaceVariant,
      outline: SereneFocusColors.outline,
      outlineVariant: SereneFocusColors.outlineVariant,
      error: SereneFocusColors.error,
      errorContainer: SereneFocusColors.errorContainer,
    );

    final textTheme = SereneFocusTypography.textTheme();

    return ThemeData(
      useMaterial3: true,
      fontFamily: SereneFocusTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SereneFocusColors.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: SereneFocusColors.surface,
        foregroundColor: SereneFocusColors.onSurface,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: SereneFocusColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SereneFocusSpacing.cardRadius),
          side: const BorderSide(color: SereneFocusColors.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SereneFocusColors.primary,
          foregroundColor: SereneFocusColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: SereneFocusSpacing.lg,
            vertical: SereneFocusSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SereneFocusSpacing.buttonRadius),
          ),
          textStyle: SereneFocusTypography.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: SereneFocusColors.secondaryContainer,
          foregroundColor: SereneFocusColors.primary,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(
            horizontal: SereneFocusSpacing.lg,
            vertical: SereneFocusSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SereneFocusSpacing.buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: SereneFocusSpacing.sm),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: SereneFocusColors.outlineVariant),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: SereneFocusColors.primary, width: 2),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: SereneFocusColors.onSurfaceVariant,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SereneFocusColors.surfaceContainerLowest,
        selectedColor: SereneFocusColors.secondaryContainer,
        labelStyle: textTheme.bodyMedium!,
        side: const BorderSide(color: SereneFocusColors.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SereneFocusSpacing.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return SereneFocusColors.surfaceContainerLowest;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SereneFocusColors.successTrack;
          }
          return SereneFocusColors.surfaceContainerHigh;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SereneFocusColors.surfaceContainerLowest,
        indicatorColor: SereneFocusColors.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return SereneFocusTypography.outfit(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            height: 16 / 12,
            color: selected
                ? SereneFocusColors.primary
                : SereneFocusColors.onSurfaceVariant,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: SereneFocusColors.surfaceVariant,
        thickness: 1,
      ),
    );
  }
}
