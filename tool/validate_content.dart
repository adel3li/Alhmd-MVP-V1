/// Content validator — spec §10.4. Run in CI and before every release:
///
///   dart run tool/validate_content.dart            # PR / development gate
///   dart run tool/validate_content.dart --release  # release gate (≥30 approved)
///
/// Fails (exit 1) if:
///  - the JSON doesn't parse or violates the §5 schema (required fields,
///    enum values) — enforced by reusing the app's own model parsing;
///  - any approved entry has quran.verified == false or
///    hadith.gradeVerified == false;
///  - duplicate `id` or `order` values exist;
///  - istisharSteps are out of order or don't end with a `hamd` step;
///  - --release: fewer than 30 approved entries exist.
library;

import 'dart:convert';
import 'dart:io';

import 'package:alhamd/data/models/blessing.dart';

const int minApprovedForRelease = 30;

Never _fail(String message) {
  stderr.writeln('✗ $message');
  exit(1);
}

void main(List<String> args) {
  final releaseMode = args.contains('--release');
  final errors = <String>[];

  final file = File('assets/content/blessings_ar.json');
  if (!file.existsSync()) {
    _fail('assets/content/blessings_ar.json not found');
  }

  final ContentDatabase db;
  try {
    final decoded = json.decode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) {
      _fail('content root must be a JSON object');
    }
    db = ContentDatabase.fromJson(decoded);
  } on FormatException catch (e) {
    _fail('schema violation: ${e.message}');
  }

  final seenIds = <String>{};
  final seenOrders = <int>{};
  for (final blessing in db.blessings) {
    final id = blessing.id;
    if (!seenIds.add(id)) {
      errors.add('duplicate id "$id"');
    }
    if (!seenOrders.add(blessing.order)) {
      errors.add('$id: duplicate order ${blessing.order}');
    }

    var lastStep = 0;
    for (final step in blessing.istisharSteps) {
      if (step.step <= lastStep) {
        errors.add('$id: istisharSteps numbers must be strictly increasing');
        break;
      }
      lastStep = step.step;
    }
    if (blessing.istisharSteps.last.type != IstisharStepType.hamd) {
      errors.add('$id: istisharSteps must end with a "hamd" step');
    }

    if (blessing.reviewStatus == ReviewStatus.approved) {
      final quran = blessing.quran;
      if (quran != null && !quran.verified) {
        errors.add('$id: approved entry with quran.verified == false');
      }
      final hadith = blessing.hadith;
      if (hadith != null && !hadith.gradeVerified) {
        errors.add('$id: approved entry with hadith.gradeVerified == false');
      }
    }
  }

  final approvedCount = db.blessings
      .where((b) => b.reviewStatus == ReviewStatus.approved)
      .length;
  if (releaseMode && approvedCount < minApprovedForRelease) {
    errors.add(
      'release gate: only $approvedCount approved entries '
      '(minimum $minApprovedForRelease) — spec §5',
    );
  }

  // The fixed-texts asset must at least parse.
  final fixedFile = File('assets/content/fixed_texts_ar.json');
  if (fixedFile.existsSync()) {
    try {
      json.decode(fixedFile.readAsStringSync());
    } on FormatException catch (e) {
      errors.add('fixed_texts_ar.json: ${e.message}');
    }
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln('✗ $error');
    }
    exit(1);
  }

  stdout.writeln(
    '✓ content valid: ${db.blessings.length} entries, '
    '$approvedCount approved${releaseMode ? ' (release gate passed)' : ''}',
  );
}
