import 'package:alhamd/core/utils/time_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextDailyOccurrence (§11.1 next-occurrence logic)', () {
    test('later today when the time has not passed', () {
      final now = DateTime(2026, 6, 11, 6, 0);
      expect(
        nextDailyOccurrence(now, 7, 0),
        DateTime(2026, 6, 11, 7, 0),
      );
    });

    test('tomorrow when the time already passed', () {
      final now = DateTime(2026, 6, 11, 7, 1);
      expect(
        nextDailyOccurrence(now, 7, 0),
        DateTime(2026, 6, 12, 7, 0),
      );
    });

    test('exact boundary rolls to tomorrow (strictly after)', () {
      final now = DateTime(2026, 6, 11, 7, 0);
      expect(
        nextDailyOccurrence(now, 7, 0),
        DateTime(2026, 6, 12, 7, 0),
      );
    });

    test('crosses month boundaries', () {
      final now = DateTime(2026, 6, 30, 23, 30);
      expect(
        nextDailyOccurrence(now, 7, 0),
        DateTime(2026, 7, 1, 7, 0),
      );
    });

    test('crosses year boundaries', () {
      final now = DateTime(2026, 12, 31, 23, 30);
      expect(
        nextDailyOccurrence(now, 7, 0),
        DateTime(2027, 1, 1, 7, 0),
      );
    });
  });
}
