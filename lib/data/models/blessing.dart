/// Content model for assets/content/blessings_ar.json — spec §5.
///
/// SACRED CONTENT RULE: the values held by [QuranVerse], [HadithRef], and
/// [ScholarQuote] are read-only sacred content. Code may move and render
/// them — never edit, generate, or "fix" them.
///
/// This file is pure Dart (no Flutter imports) so that
/// tool/validate_content.dart can reuse the exact same parsing in CI.
library;

/// Categories follow Maqasid al-Shari'ah + the prophetic ranking — spec §5.
enum BlessingCategory {
  din('din'),
  nafs('nafs'),
  aql('aql'),
  nasl('nasl'),
  mal('mal'),
  amn('amn'),
  afiyah('afiyah'),
  rizq('rizq');

  const BlessingCategory(this.jsonValue);
  final String jsonValue;

  static BlessingCategory parse(Object? value, String context) {
    final match = values.where((v) => v.jsonValue == value);
    if (match.isEmpty) {
      throw FormatException(
        '$context: unknown category "$value" '
        '(expected one of ${values.map((v) => v.jsonValue).join(' | ')})',
      );
    }
    return match.first;
  }
}

enum ReviewStatus {
  draft('draft'),
  pendingReview('pending_review'),
  approved('approved'),
  needsCorrection('needs_correction');

  const ReviewStatus(this.jsonValue);
  final String jsonValue;

  static ReviewStatus parse(Object? value, String context) {
    final match = values.where((v) => v.jsonValue == value);
    if (match.isEmpty) {
      throw FormatException(
        '$context: unknown reviewStatus "$value" '
        '(expected one of ${values.map((v) => v.jsonValue).join(' | ')})',
      );
    }
    return match.first;
  }
}

enum AttributionType {
  verbatim('verbatim'),
  paraphrase('paraphrase');

  const AttributionType(this.jsonValue);
  final String jsonValue;

  static AttributionType parse(Object? value, String context) {
    final match = values.where((v) => v.jsonValue == value);
    if (match.isEmpty) {
      throw FormatException(
        '$context: unknown attributionType "$value" '
        '(expected one of ${values.map((v) => v.jsonValue).join(' | ')})',
      );
    }
    return match.first;
  }
}

enum IstisharStepType {
  ground('ground'),
  visualize('visualize'),
  deepen('deepen'),
  returnStep('return'),
  hamd('hamd');

  const IstisharStepType(this.jsonValue);
  final String jsonValue;

  static IstisharStepType parse(Object? value, String context) {
    final match = values.where((v) => v.jsonValue == value);
    if (match.isEmpty) {
      throw FormatException(
        '$context: unknown istishar step type "$value" '
        '(expected one of ${values.map((v) => v.jsonValue).join(' | ')})',
      );
    }
    return match.first;
  }
}

String _requireString(Map<String, Object?> json, String key, String context) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('$context: missing or empty required field "$key"');
  }
  return value;
}

int _requireInt(Map<String, Object?> json, String key, String context) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('$context: missing or non-integer field "$key"');
  }
  return value;
}

class QuranVerse {
  const QuranVerse({
    required this.textUthmani,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.verified,
  });

  factory QuranVerse.fromJson(Map<String, Object?> json, String context) {
    return QuranVerse(
      textUthmani: _requireString(json, 'textUthmani', context),
      surahName: _requireString(json, 'surahName', context),
      surahNumber: _requireInt(json, 'surahNumber', context),
      ayahNumber: _requireInt(json, 'ayahNumber', context),
      verified: json['verified'] == true,
    );
  }

  final String textUthmani;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final bool verified;
}

class HadithRef {
  const HadithRef({
    required this.text,
    required this.source,
    required this.grade,
    required this.gradeVerified,
    this.number,
  });

  factory HadithRef.fromJson(Map<String, Object?> json, String context) {
    return HadithRef(
      text: _requireString(json, 'text', context),
      source: _requireString(json, 'source', context),
      grade: _requireString(json, 'grade', context),
      gradeVerified: json['gradeVerified'] == true,
      number: json['number'] as String?,
    );
  }

  final String text;
  final String source;
  final String? number;
  final String grade;
  final bool gradeVerified;
}

class ScholarQuote {
  const ScholarQuote({
    required this.text,
    required this.scholar,
    required this.attributionType,
    required this.verifiedVerbatim,
    this.work,
  });

  factory ScholarQuote.fromJson(Map<String, Object?> json, String context) {
    return ScholarQuote(
      text: _requireString(json, 'text', context),
      scholar: _requireString(json, 'scholar', context),
      work: json['work'] as String?,
      attributionType:
          AttributionType.parse(json['attributionType'], context),
      verifiedVerbatim: json['verifiedVerbatim'] == true,
    );
  }

  final String text;
  final String scholar;
  final String? work;
  final AttributionType attributionType;
  final bool verifiedVerbatim;
}

class IstisharStep {
  const IstisharStep({
    required this.step,
    required this.type,
    required this.text,
    required this.durationSec,
  });

  factory IstisharStep.fromJson(Map<String, Object?> json, String context) {
    final step = IstisharStep(
      step: _requireInt(json, 'step', context),
      type: IstisharStepType.parse(json['type'], context),
      text: _requireString(json, 'text', context),
      durationSec: _requireInt(json, 'durationSec', context),
    );
    if (step.durationSec <= 0) {
      throw FormatException('$context: durationSec must be positive');
    }
    return step;
  }

  final int step;
  final IstisharStepType type;
  final String text;
  final int durationSec;
}

class Blessing {
  const Blessing({
    required this.id,
    required this.order,
    required this.category,
    required this.categoryLabel,
    required this.title,
    required this.shortTitle,
    required this.openingLine,
    required this.istisharSteps,
    required this.reviewStatus,
    required this.contentVersion,
    this.quran,
    this.hadith,
    this.scholarQuote,
    this.tadabbur,
    this.duaa,
    this.journalPrompt,
    this.relatedPodcastEpisode,
    this.reviewedBy,
    this.reviewDate,
  });

  factory Blessing.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final context = id is String && id.isNotEmpty ? id : '<missing id>';
    if (id is! String || id.isEmpty) {
      throw FormatException('$context: missing required field "id"');
    }

    final stepsJson = json['istisharSteps'];
    if (stepsJson is! List || stepsJson.isEmpty) {
      throw FormatException(
        '$context: "istisharSteps" must be a non-empty list',
      );
    }
    final steps = <IstisharStep>[];
    for (final (i, raw) in stepsJson.indexed) {
      if (raw is! Map<String, Object?>) {
        throw FormatException('$context: istisharSteps[$i] is not an object');
      }
      steps.add(IstisharStep.fromJson(raw, '$context.istisharSteps[$i]'));
    }

    final quranJson = json['quran'];
    final hadithJson = json['hadith'];
    final scholarJson = json['scholarQuote'];

    return Blessing(
      id: id,
      order: _requireInt(json, 'order', context),
      category: BlessingCategory.parse(json['category'], context),
      categoryLabel: _requireString(json, 'categoryLabel', context),
      title: _requireString(json, 'title', context),
      shortTitle: _requireString(json, 'shortTitle', context),
      openingLine: _requireString(json, 'openingLine', context),
      istisharSteps: List.unmodifiable(steps),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'], context),
      contentVersion: _requireInt(json, 'contentVersion', context),
      quran: quranJson is Map<String, Object?>
          ? QuranVerse.fromJson(quranJson, '$context.quran')
          : null,
      hadith: hadithJson is Map<String, Object?>
          ? HadithRef.fromJson(hadithJson, '$context.hadith')
          : null,
      scholarQuote: scholarJson is Map<String, Object?>
          ? ScholarQuote.fromJson(scholarJson, '$context.scholarQuote')
          : null,
      tadabbur: json['tadabbur'] as String?,
      duaa: json['duaa'] as String?,
      journalPrompt: json['journalPrompt'] as String?,
      relatedPodcastEpisode: json['relatedPodcastEpisode'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      reviewDate: json['reviewDate'] as String?,
    );
  }

  final String id;
  final int order;
  final BlessingCategory category;
  final String categoryLabel;
  final String title;
  final String shortTitle;
  final String openingLine;
  final QuranVerse? quran;
  final HadithRef? hadith;
  final ScholarQuote? scholarQuote;
  final List<IstisharStep> istisharSteps;
  final String? tadabbur;
  final String? duaa;
  final String? journalPrompt;
  final String? relatedPodcastEpisode;
  final ReviewStatus reviewStatus;
  final String? reviewedBy;
  final String? reviewDate;
  final int contentVersion;
}

class ContentDatabase {
  const ContentDatabase({required this.schemaVersion, required this.blessings});

  factory ContentDatabase.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int) {
      throw const FormatException('content: missing integer "schemaVersion"');
    }
    final list = json['blessings'];
    if (list is! List) {
      throw const FormatException('content: "blessings" must be a list');
    }
    final blessings = <Blessing>[];
    for (final (i, raw) in list.indexed) {
      if (raw is! Map<String, Object?>) {
        throw FormatException('content: blessings[$i] is not an object');
      }
      blessings.add(Blessing.fromJson(raw));
    }
    return ContentDatabase(
      schemaVersion: schemaVersion,
      blessings: List.unmodifiable(blessings),
    );
  }

  final int schemaVersion;
  final List<Blessing> blessings;
}
