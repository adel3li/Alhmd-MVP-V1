/// Eastern Arabic numerals (٠١٢٣…) for all user-facing numbers — spec §3.3.
const Map<String, String> _westernToEastern = {
  '0': '٠',
  '1': '١',
  '2': '٢',
  '3': '٣',
  '4': '٤',
  '5': '٥',
  '6': '٦',
  '7': '٧',
  '8': '٨',
  '9': '٩',
};

/// Replaces any Western digits in [input] with Eastern Arabic digits.
/// Already-Eastern digits pass through unchanged (idempotent).
String toArabicDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_westernToEastern[char] ?? char);
  }
  return buffer.toString();
}

/// Formats an integer using Eastern Arabic digits.
String arabicNumber(int value) => toArabicDigits(value.toString());
