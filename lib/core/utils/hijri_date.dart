import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import 'arabic_digits.dart';

/// Hijri + Gregorian date display helpers — spec §3.3.
///
/// All output uses Eastern Arabic digits and Arabic month names, e.g.
/// «١٥ ذو الحجة ١٤٤٧».
abstract final class HijriDateFormatter {
  static bool _localeSet = false;

  static void _ensureArabicLocale() {
    if (!_localeSet) {
      HijriCalendar.setLocal('ar');
      _localeSet = true;
    }
  }

  /// «١٥ ذو الحجة ١٤٤٧»
  static String formatHijri(DateTime date) {
    _ensureArabicLocale();
    final h = HijriCalendar.fromDate(date);
    return '${arabicNumber(h.hDay)} ${h.longMonthName} ${arabicNumber(h.hYear)}';
  }

  /// Hijri month + year only, e.g. «ذو الحجة ١٤٤٧».
  static String formatHijriMonthYear(int hYear, int hMonth) {
    _ensureArabicLocale();
    final h = HijriCalendar()
      ..hYear = hYear
      ..hMonth = hMonth
      ..hDay = 1;
    // longMonthName is populated by toFormat with the active locale.
    final monthName = h.toFormat('MMMM');
    return '$monthName ${arabicNumber(hYear)}';
  }

  /// Gregorian date in Arabic, e.g. «١١ يونيو ٢٠٢٦».
  static String formatGregorian(DateTime date) {
    final formatted = DateFormat('d MMMM y', 'ar').format(date);
    return toArabicDigits(formatted);
  }

  static HijriCalendar hijriFromDate(DateTime date) {
    _ensureArabicLocale();
    return HijriCalendar.fromDate(date);
  }

  /// Today's Hijri calendar (for the consistency grid).
  static HijriCalendar today() => hijriFromDate(DateTime.now());
}
