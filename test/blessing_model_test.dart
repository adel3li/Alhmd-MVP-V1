import 'dart:convert';
import 'dart:io';

import 'package:alhamd/data/models/blessing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/content_fixtures.dart';

void main() {
  group('bundled content database', () {
    test('parses and respects schema invariants', () {
      final raw =
          File('assets/content/blessings_ar.json').readAsStringSync();
      final db = ContentDatabase.fromJson(
        json.decode(raw) as Map<String, Object?>,
      );

      expect(db.schemaVersion, 2);
      expect(db.blessings, isNotEmpty);

      final ids = {for (final b in db.blessings) b.id};
      expect(ids.length, db.blessings.length, reason: 'duplicate ids');
      final orders = {for (final b in db.blessings) b.order};
      expect(orders.length, db.blessings.length, reason: 'duplicate orders');

      for (final b in db.blessings) {
        expect(b.istisharSteps, isNotEmpty);
        expect(
          b.istisharSteps.last.type,
          IstisharStepType.hamd,
          reason: '${b.id} flow must end with hamd',
        );
        // Approved sacred content must be verification-flagged (§5).
        if (b.reviewStatus == ReviewStatus.approved && b.quran != null) {
          expect(b.quran!.verified, isTrue);
        }
        if (b.reviewStatus == ReviewStatus.approved && b.hadith != null) {
          expect(b.hadith!.gradeVerified, isTrue);
        }
      }
    });
  });

  group('malformed content', () {
    test('missing required field names the entry and field', () {
      final bad = blessingJson()..remove('title');
      expect(
        () => Blessing.fromJson(bad),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('"title"'),
          ),
        ),
      );
    });

    test('unknown category is rejected with the allowed values', () {
      final bad = blessingJson()..['category'] = 'dunya';
      expect(
        () => Blessing.fromJson(bad),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('category'),
          ),
        ),
      );
    });

    test('unknown reviewStatus is rejected', () {
      final bad = blessingJson(reviewStatus: 'published');
      expect(() => Blessing.fromJson(bad), throwsFormatException);
    });

    test('empty istisharSteps is rejected', () {
      final bad = blessingJson()..['istisharSteps'] = <Object?>[];
      expect(() => Blessing.fromJson(bad), throwsFormatException);
    });

    test('non-positive step duration is rejected', () {
      final bad = blessingJson(
        steps: [
          {'step': 1, 'type': 'hamd', 'text': 'x', 'durationSec': 0},
        ],
      );
      expect(() => Blessing.fromJson(bad), throwsFormatException);
    });

    test('root without blessings list is rejected', () {
      expect(
        () => ContentDatabase.fromJson(const {'schemaVersion': 2}),
        throwsFormatException,
      );
    });
  });
}
