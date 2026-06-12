import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/blessing.dart';

/// Read-only access to the bundled content database — spec §4/§5.
/// Sacred texts anchored to fixed UI surfaces (not blessings), e.g. the
/// consistency-screen hadith — sourced from assets/content/fixed_texts_ar.json
/// so they stay human-reviewable and never live in widgets or ARB (§3.2).
class FixedTexts {
  const FixedTexts({this.consistencyHadithText, this.consistencyHadithAttribution});

  final String? consistencyHadithText;
  final String? consistencyHadithAttribution;
}

class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String assetPath = 'assets/content/blessings_ar.json';
  static const String fixedTextsAssetPath =
      'assets/content/fixed_texts_ar.json';

  final AssetBundle _bundle;
  ContentDatabase? _cache;
  FixedTexts? _fixedTextsCache;

  Future<ContentDatabase> load() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(assetPath);
    final decoded = json.decode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('content: root must be a JSON object');
    }
    return _cache = ContentDatabase.fromJson(decoded);
  }

  /// The publishable list, sorted by `order`.
  ///
  /// Release builds select from `approved` entries only (spec §5). Debug
  /// builds additionally include `pending_review` so development isn't
  /// blocked while scholarly review is in flight — CI guarantees a release
  /// can never ship with under 30 approved entries.
  Future<List<Blessing>> published() async {
    final db = await load();
    return publishedFrom(db.blessings, releaseMode: kReleaseMode);
  }

  /// Today's blessing, or null when nothing is publishable.
  Future<Blessing?> blessingForDate(DateTime date) async {
    return selectForDate(await published(), date);
  }

  Future<FixedTexts> fixedTexts() async {
    if (_fixedTextsCache != null) return _fixedTextsCache!;
    try {
      final raw = await _bundle.loadString(fixedTextsAssetPath);
      final decoded = json.decode(raw);
      if (decoded is! Map<String, Object?>) return _fixedTextsCache = const FixedTexts();
      final hadith = decoded['consistencyHadith'];
      if (hadith is! Map<String, Object?>) return _fixedTextsCache = const FixedTexts();
      return _fixedTextsCache = FixedTexts(
        consistencyHadithText: hadith['text'] as String?,
        consistencyHadithAttribution: hadith['attribution'] as String?,
      );
    } on Exception {
      return _fixedTextsCache = const FixedTexts();
    }
  }

  /// The onboarding anchor verse ﴿قُلْ أَرَأَيْتُمْ إِنْ أَصْبَحَ مَاؤُكُمْ غَوْرًا…﴾
  /// (§6.1) — read from the content database (الملك ٦٧:٣٠) so sacred text
  /// stays single-sourced. Returns null if that entry isn't bundled.
  Future<QuranVerse?> onboardingAnchorVerse() async {
    final db = await load();
    for (final blessing in db.blessings) {
      final verse = blessing.quran;
      if (verse != null && verse.surahNumber == 67 && verse.ayahNumber == 30) {
        return verse;
      }
    }
    return null;
  }

  @visibleForTesting
  static List<Blessing> publishedFrom(
    List<Blessing> all, {
    required bool releaseMode,
  }) {
    final eligible = all
        .where(
          (b) =>
              b.reviewStatus == ReviewStatus.approved ||
              (!releaseMode && b.reviewStatus == ReviewStatus.pendingReview),
        )
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return eligible;
  }

  /// Deterministic daily selection — spec §4 rule 3:
  /// `blessings[dayOfYear % published.length]`, same for every user on the
  /// same date, stable across restarts, fully offline.
  static Blessing? selectForDate(List<Blessing> published, DateTime date) {
    if (published.isEmpty) return null;
    return published[dayOfYear(date) % published.length];
  }

  /// 1-based day of year in local time.
  static int dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year);
    final startOfDay = DateTime(date.year, date.month, date.day);
    return startOfDay.difference(startOfYear).inDays + 1;
  }
}
