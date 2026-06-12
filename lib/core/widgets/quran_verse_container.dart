import 'package:flutter/material.dart';

import '../../data/models/blessing.dart';
import '../../l10n/l10n.dart';
import '../theme/theme.dart';
import '../utils/arabic_digits.dart';

/// Quranic verse display — always Amiri, always inside the quranBg container
/// with ﴿ ﴾ ornamental brackets and the surah:ayah reference beneath (§3.2).
/// Quranic text is start-aligned, never justified.
class QuranVerseContainer extends StatelessWidget {
  const QuranVerseContainer({required this.verse, super.key});

  final QuranVerse verse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: colors.quranBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '﴿${verse.textUthmani}﴾',
            style: AppTypography.quran.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.quranSurahRef(
              verse.surahName,
              arabicNumber(verse.ayahNumber),
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
