import 'package:flutter/material.dart';

/// Font families bundled in assets/fonts (spec §3.2).
abstract final class AppFonts {
  /// Quranic verses, hadith, and scholar quotes only.
  static const String amiri = 'Amiri';

  /// Everything else.
  static const String plexArabic = 'IBMPlexSansArabic';
}

/// Typographic scale — spec §3.2.
///
/// Rules: never letter-space Arabic; never justify Quranic text (use start
/// alignment); Quran is always Amiri inside the quranBg container.
abstract final class AppTypography {
  /// Quranic verses: Amiri 24–28sp, line-height 2.0, harakāt preserved.
  static const TextStyle quran = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 26,
    height: 2,
  );

  /// Hadith & scholar quotes: Amiri 20sp, line-height 1.9.
  static const TextStyle hadith = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 20,
    height: 1.9,
  );

  /// Large display for the blessing title (Amiri per §6.2).
  static const TextStyle blessingTitle = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.6,
  );

  static TextTheme textTheme(Color textPrimary, Color textSecondary) {
    return TextTheme(
      // Screen titles: IBM Plex Sans Arabic SemiBold 22sp.
      titleLarge: TextStyle(
        fontFamily: AppFonts.plexArabic,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.plexArabic,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: textPrimary,
      ),
      // Body / UI: 16sp, line-height 1.7.
      bodyLarge: TextStyle(
        fontFamily: AppFonts.plexArabic,
        fontSize: 18,
        height: 1.7,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.plexArabic,
        fontSize: 16,
        height: 1.7,
        color: textPrimary,
      ),
      // Captions / metadata: 13sp, textSecondary.
      bodySmall: TextStyle(
        fontFamily: AppFonts.plexArabic,
        fontSize: 13,
        height: 1.6,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.plexArabic,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.plexArabic,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: textPrimary,
      ),
    );
  }
}
