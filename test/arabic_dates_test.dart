import 'package:alhamd/core/utils/arabic_digits.dart';
import 'package:alhamd/core/utils/hijri_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('Eastern Arabic digits (§3.3)', () {
    test('maps all Western digits', () {
      expect(toArabicDigits('0123456789'), '٠١٢٣٤٥٦٧٨٩');
    });

    test('is idempotent and preserves non-digits', () {
      expect(toArabicDigits('١٤٤٧ هـ — 2026'), '١٤٤٧ هـ — ٢٠٢٦');
    });

    test('arabicNumber formats ints', () {
      expect(arabicNumber(365), '٣٦٥');
    });
  });

  group('Hijri/Gregorian formatting', () {
    setUpAll(() => initializeDateFormatting('ar'));

    test('formatHijri uses Arabic month names and Eastern digits', () {
      final formatted = HijriDateFormatter.formatHijri(DateTime(2026, 6, 11));
      expect(formatted, isNot(matches(RegExp('[0-9]'))));
      expect(formatted, matches(RegExp('[٠-٩]')));
      // 2026-06-11 falls in late ذو الحجة 1447 / early محرم 1448.
      expect(formatted, matches(RegExp('١٤٤[٧٨]')));
    });

    test('formatGregorian uses Eastern digits', () {
      final formatted =
          HijriDateFormatter.formatGregorian(DateTime(2026, 6, 11));
      expect(formatted, isNot(matches(RegExp('[0-9]'))));
      expect(formatted, contains('٢٠٢٦'));
    });

    test('hijri month/year header has no Western digits', () {
      final formatted = HijriDateFormatter.formatHijriMonthYear(1447, 12);
      expect(formatted, contains('١٤٤٧'));
      expect(formatted, isNot(matches(RegExp('[0-9]'))));
    });
  });
}
