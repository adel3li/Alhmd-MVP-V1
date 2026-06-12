import 'package:flutter/material.dart';

/// Palette «وقار» (light) — spec §3.1.
abstract final class AppColorsLight {
  static const Color background = Color(0xFFFAF6EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1F2A4A);
  static const Color accent = Color(0xFFB89B5E);
  static const Color textPrimary = Color(0xFF22283B);

  /// Spec value #6B7080 measured 4.23:1 against [quranBg] — below the §3.1
  /// WCAG AA floor for the caption text that sits there (surah reference,
  /// hadith grading). Darkened minimally to clear 4.5:1 on every surface.
  static const Color textSecondary = Color(0xFF656A79);
  static const Color quranBg = Color(0xFFF4EDDC);
  static const Color success = Color(0xFF4C7A5C);
}

/// Palette «سكينة» (dark) — spec §3.1. Also forced during the استشعار flow.
abstract final class AppColorsDark {
  static const Color background = Color(0xFF141B2E);
  static const Color surface = Color(0xFF1C2540);
  static const Color primary = Color(0xFFE8DCC0);
  static const Color accent = Color(0xFFC9AC6E);
  static const Color textPrimary = Color(0xFFF2EDE2);
  static const Color textSecondary = Color(0xFFA9AFC0);
  static const Color quranBg = Color(0xFF1A2238);
  static const Color success = Color(0xFF6FA383);
}

/// Theme extension carrying the tokens that don't map onto [ColorScheme].
///
/// Contrast rule (§3.1): every pair exposed here that carries text passes
/// WCAG AA — asserted by test/theme_contrast_test.dart. The gold [accent]
/// must never carry body-size text directly on [background] in the light
/// theme (2.5:1) — it is reserved for fills, borders, and dividers; text on
/// top of a gold fill uses [ColorScheme.onSecondary].
@immutable
class AlhamdColors extends ThemeExtension<AlhamdColors> {
  const AlhamdColors({
    required this.accent,
    required this.quranBg,
    required this.success,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color accent;
  final Color quranBg;
  final Color success;
  final Color textPrimary;
  final Color textSecondary;

  static const AlhamdColors light = AlhamdColors(
    accent: AppColorsLight.accent,
    quranBg: AppColorsLight.quranBg,
    success: AppColorsLight.success,
    textPrimary: AppColorsLight.textPrimary,
    textSecondary: AppColorsLight.textSecondary,
  );

  static const AlhamdColors dark = AlhamdColors(
    accent: AppColorsDark.accent,
    quranBg: AppColorsDark.quranBg,
    success: AppColorsDark.success,
    textPrimary: AppColorsDark.textPrimary,
    textSecondary: AppColorsDark.textSecondary,
  );

  @override
  AlhamdColors copyWith({
    Color? accent,
    Color? quranBg,
    Color? success,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AlhamdColors(
      accent: accent ?? this.accent,
      quranBg: quranBg ?? this.quranBg,
      success: success ?? this.success,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AlhamdColors lerp(ThemeExtension<AlhamdColors>? other, double t) {
    if (other is! AlhamdColors) return this;
    return AlhamdColors(
      accent: Color.lerp(accent, other.accent, t)!,
      quranBg: Color.lerp(quranBg, other.quranBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension AlhamdColorsX on ThemeData {
  AlhamdColors get alhamd => extension<AlhamdColors>()!;
}
