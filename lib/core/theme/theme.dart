import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

export 'colors.dart';
export 'typography.dart';

/// Builds the «وقار» light and «سكينة» dark themes — spec §3.
abstract final class AppTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: AppColorsLight.background,
        surface: AppColorsLight.surface,
        primary: AppColorsLight.primary,
        onPrimary: AppColorsLight.background,
        accent: AppColorsLight.accent,
        onAccent: AppColorsLight.primary,
        ext: AlhamdColors.light,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: AppColorsDark.background,
        surface: AppColorsDark.surface,
        primary: AppColorsDark.primary,
        onPrimary: AppColorsDark.background,
        accent: AppColorsDark.accent,
        onAccent: AppColorsDark.background,
        ext: AlhamdColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color accent,
    required Color onAccent,
    required AlhamdColors ext,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: accent,
      onSecondary: onAccent,
      error: brightness == Brightness.light
          ? const Color(0xFF8C3A3A)
          : const Color(0xFFD89090),
      onError: brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF141B2E),
      surface: surface,
      onSurface: ext.textPrimary,
      onSurfaceVariant: ext.textSecondary,
      outline: ext.textSecondary,
    );

    final textTheme = AppTypography.textTheme(ext.textPrimary, ext.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppFonts.plexArabic,
      textTheme: textTheme,
      extensions: [ext],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ext.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Primary CTA: gold fill, dark label (passes AA — see colors.dart).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ext.textPrimary,
          minimumSize: const Size.fromHeight(48),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: ext.textSecondary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ext.textPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: accent.withValues(alpha: 0.35),
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: onPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium!.copyWith(color: ext.textSecondary),
        contentPadding: const EdgeInsetsDirectional.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.textSecondary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.textSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}
