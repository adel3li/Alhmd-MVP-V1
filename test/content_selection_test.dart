import 'package:alhamd/data/models/blessing.dart';
import 'package:alhamd/data/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/content_fixtures.dart';

void main() {
  group('dayOfYear', () {
    test('jan 1 is day 1', () {
      expect(ContentRepository.dayOfYear(DateTime(2026, 1, 1)), 1);
    });

    test('dec 31 is 365 in a non-leap year', () {
      expect(ContentRepository.dayOfYear(DateTime(2026, 12, 31)), 365);
    });

    test('dec 31 is 366 in a leap year', () {
      expect(ContentRepository.dayOfYear(DateTime(2028, 12, 31)), 366);
    });

    test('time of day does not change the day index', () {
      expect(
        ContentRepository.dayOfYear(DateTime(2026, 6, 11, 23, 59)),
        ContentRepository.dayOfYear(DateTime(2026, 6, 11, 0, 1)),
      );
    });
  });

  group('deterministic daily selection (spec §4 rule 3)', () {
    final published = [
      makeBlessing(id: 'b1', order: 1),
      makeBlessing(id: 'b2', order: 2),
      makeBlessing(id: 'b3', order: 3),
    ];

    test('same date always yields the same blessing', () {
      final a = ContentRepository.selectForDate(published, DateTime(2026, 6, 11, 8));
      final b = ContentRepository.selectForDate(published, DateTime(2026, 6, 11, 22));
      expect(a!.id, b!.id);
    });

    test('selection follows dayOfYear % length', () {
      final date = DateTime(2026, 6, 11); // day 162, 162 % 3 == 0
      expect(ContentRepository.selectForDate(published, date)!.id, 'b1');
      final next = DateTime(2026, 6, 12); // 163 % 3 == 1
      expect(ContentRepository.selectForDate(published, next)!.id, 'b2');
    });

    test('empty published list yields null', () {
      expect(ContentRepository.selectForDate(const [], DateTime(2026)), isNull);
    });
  });

  group('published filter', () {
    final all = [
      Blessing.fromJson(blessingJson(id: 'a', order: 3, reviewStatus: 'approved')),
      Blessing.fromJson(blessingJson(id: 'p', order: 1, reviewStatus: 'pending_review')),
      Blessing.fromJson(blessingJson(id: 'd', order: 2, reviewStatus: 'draft')),
      Blessing.fromJson(blessingJson(id: 'n', order: 4, reviewStatus: 'needs_correction')),
    ];

    test('release mode: approved only', () {
      final published =
          ContentRepository.publishedFrom(all, releaseMode: true);
      expect([for (final b in published) b.id], ['a']);
    });

    test('debug mode: approved + pending_review, sorted by order', () {
      final published =
          ContentRepository.publishedFrom(all, releaseMode: false);
      expect([for (final b in published) b.id], ['p', 'a']);
    });

    test('draft and needs_correction are never published', () {
      for (final releaseMode in [true, false]) {
        final published =
            ContentRepository.publishedFrom(all, releaseMode: releaseMode);
        expect(
          published.where(
            (b) =>
                b.reviewStatus == ReviewStatus.draft ||
                b.reviewStatus == ReviewStatus.needsCorrection,
          ),
          isEmpty,
        );
      }
    });
  });
}
