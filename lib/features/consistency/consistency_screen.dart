import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/providers.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/arabic_digits.dart';
import '../../core/utils/hijri_date.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../l10n/l10n.dart';

final _fixedTextsProvider = FutureProvider<FixedTexts>(
  (ref) => ref.watch(contentRepositoryProvider).fixedTexts(),
);

/// المداومة — محاسبة النفس view (§6.5). Deliberately NOT gamified: neutral
/// dots, no streak counters, no flames; missed days are simply empty.
class ConsistencyScreen extends ConsumerStatefulWidget {
  const ConsistencyScreen({super.key});

  @override
  ConsumerState<ConsistencyScreen> createState() => _ConsistencyScreenState();
}

class _ConsistencyScreenState extends ConsumerState<ConsistencyScreen> {
  late int _hYear;
  late int _hMonth;

  @override
  void initState() {
    super.initState();
    final today = HijriDateFormatter.today();
    _hYear = today.hYear;
    _hMonth = today.hMonth;
  }

  void _previousMonth() {
    setState(() {
      _hMonth -= 1;
      if (_hMonth < 1) {
        _hMonth = 12;
        _hYear -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _hMonth += 1;
      if (_hMonth > 12) {
        _hMonth = 1;
        _hYear += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final completions = ref.watch(completionsProvider).value ?? const [];
    final completedKeys = {for (final c in completions) c.dayKey};
    final fixedTexts = ref.watch(_fixedTextsProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consistencyTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(20),
        children: [
          if (fixedTexts?.consistencyHadithText != null)
            _HadithHeader(
              text: fixedTexts!.consistencyHadithText!,
              attribution: fixedTexts.consistencyHadithAttribution ?? '',
            ),
          const SizedBox(height: 12),
          Text(
            l10n.consistencySubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // In RTL, "previous" advances visually to the right.
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_right),
              ),
              Expanded(
                child: Text(
                  HijriDateFormatter.formatHijriMonthYear(_hYear, _hMonth),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_left),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MonthGrid(
            hYear: _hYear,
            hMonth: _hMonth,
            completedKeys: completedKeys,
          ),
        ],
      ),
    );
  }
}

/// Header hadith with its attribution caption — text comes from the content
/// assets, never hardcoded in widgets (§3.2).
class _HadithHeader extends StatelessWidget {
  const _HadithHeader({required this.text, required this.attribution});

  final String text;
  final String attribution;

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
            '«$text»',
            style: AppTypography.hadith.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(attribution, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.hYear,
    required this.hMonth,
    required this.completedKeys,
  });

  final int hYear;
  final int hMonth;
  final Set<String> completedKeys;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    final l10n = context.l10n;

    final calendar = HijriCalendar();
    final daysInMonth = calendar.getDaysInMonth(hYear, hMonth);
    final firstDayGregorian = calendar.hijriToGregorian(hYear, hMonth, 1);
    // Grid weeks start on الأحد (Sunday). DateTime.weekday: Mon=1 … Sun=7.
    final leadingBlanks = firstDayGregorian.weekday % 7;
    final today = DateTime.now();
    final todayKey = JournalRepository.dayKeyFor(today);

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final gregorian = calendar.hijriToGregorian(hYear, hMonth, day);
      final key = JournalRepository.dayKeyFor(gregorian);
      final completed = completedKeys.contains(key);
      final isToday = key == todayKey;
      final isFuture = gregorian.isAfter(today);
      cells.add(
        _DayCell(
          day: day,
          completed: completed,
          isToday: isToday,
          isFuture: isFuture,
          semanticLabel: completed ? l10n.consistencyDayCompletedSemantics : null,
          colors: colors,
          theme: theme,
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.completed,
    required this.isToday,
    required this.isFuture,
    required this.colors,
    required this.theme,
    this.semanticLabel,
  });

  final int day;
  final bool completed;
  final bool isToday;
  final bool isFuture;
  final String? semanticLabel;
  final AlhamdColors colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cell = Container(
      decoration: isToday
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.7),
                width: 1.5,
              ),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            arabicNumber(day),
            style: theme.textTheme.bodySmall!.copyWith(
              color: isFuture
                  ? colors.textSecondary.withValues(alpha: 0.45)
                  : colors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? colors.accent
                  // Missed days are simply empty — never red, never
                  // "broken" (§6.5).
                  : colors.textSecondary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
    return semanticLabel == null
        ? cell
        : Semantics(label: semanticLabel, child: cell);
  }
}
