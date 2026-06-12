import 'dart:math' as math;

import 'package:alhamd/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative luminance.
double _luminance(Color c) {
  double linear(double channel) => channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linear(c.r) + 0.7152 * linear(c.g) + 0.0722 * linear(c.b);
}

double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // §3.1 contrast rule: text/background pairs pass WCAG AA — ≥4.5:1 for
  // body/caption text, ≥3:1 for large text. The light-theme gold accent is
  // excluded by design: it never carries text directly on the background
  // (fills/borders/dividers only — see AlhamdColors docs).
  group('WCAG AA contrast (§3.1)', () {
    for (final (name, theme) in [
      ('light «وقار»', AppTheme.light()),
      ('dark «سكينة»', AppTheme.dark()),
    ]) {
      group(name, () {
        final colors = theme.alhamd;
        final scheme = theme.colorScheme;
        final background = theme.scaffoldBackgroundColor;

        final bodyPairs = <String, (Color, Color)>{
          'textPrimary on background': (colors.textPrimary, background),
          'textPrimary on surface': (colors.textPrimary, scheme.surface),
          'textPrimary on quranBg': (colors.textPrimary, colors.quranBg),
          'textSecondary on background': (colors.textSecondary, background),
          'textSecondary on surface': (colors.textSecondary, scheme.surface),
          'textSecondary on quranBg': (colors.textSecondary, colors.quranBg),
          'onPrimary on primary (buttons)': (scheme.onPrimary, scheme.primary),
          'onSecondary on accent (gold CTA)': (
            scheme.onSecondary,
            scheme.secondary,
          ),
          'success on background': (colors.success, background),
        };

        bodyPairs.forEach((label, pair) {
          test('$label ≥ 4.5:1', () {
            final ratio = contrastRatio(pair.$1, pair.$2);
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$label is ${ratio.toStringAsFixed(2)}:1',
            );
          });
        });
      });
    }
  });
}
