import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/hijri_date.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/quran_verse_container.dart';
import '../../data/models/blessing.dart';
import '../../l10n/l10n.dart';
import '../settings/notification_copy.dart';
import '../settings/settings_controller.dart';

/// Home — «نعمة اليوم» (§6.2).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _loggedBlessingId;
  bool _rescheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startupTasks());
  }

  /// §7.2: refresh the notification schedule on launch (self-heals timezone
  /// changes and keeps the rolling 14-day window full).
  void _startupTasks() {
    if (_rescheduled || !mounted) return;
    _rescheduled = true;
    final copy = notificationCopyOf(context.l10n);
    Future<void>.microtask(
      () => ref.read(settingsProvider.notifier).rescheduleNotifications(copy),
    );
  }

  void _logViewed(Blessing blessing) {
    if (_loggedBlessingId == blessing.id) return;
    _loggedBlessingId = blessing.id;
    Future<void>.microtask(
      () => ref
          .read(analyticsServiceProvider)
          .dailyBlessingViewed(blessing.id, blessing.category.jsonValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final blessingAsync = ref.watch(blessingOfDayProvider);
    final completed = ref.watch(todayCompletedProvider).value ?? false;
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.greeting, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${HijriDateFormatter.formatHijri(now)} — '
                        '${HijriDateFormatter.formatGregorian(now)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.settingsTitle,
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
            const SizedBox(height: 20),
            blessingAsync.when(
              loading: () => const Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _EmptyContentCard(message: l10n.noContentAvailable),
              data: (blessing) {
                if (blessing == null) {
                  return _EmptyContentCard(message: l10n.noContentAvailable);
                }
                _logViewed(blessing);
                return _BlessingCard(blessing: blessing, completed: completed);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book_outlined, size: 20),
                    label: Text(l10n.journalTitle),
                    onPressed: () => context.push(AppRoutes.journal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month_outlined, size: 20),
                    label: Text(l10n.consistencyTitle),
                    onPressed: () => context.push(AppRoutes.consistency),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlessingCard extends StatelessWidget {
  const _BlessingCard({required this.blessing, required this.completed});

  final Blessing blessing;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    final verse = blessing.quran;

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: CategoryChip(label: blessing.categoryLabel)),
                const SizedBox(width: 8),
                Text(l10n.todaysBlessing, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              blessing.title,
              style: AppTypography.blessingTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(blessing.openingLine, style: theme.textTheme.bodyMedium),
            if (verse != null) ...[
              const SizedBox(height: 16),
              QuranVerseContainer(verse: verse),
            ],
            const SizedBox(height: 20),
            if (completed) ...[
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 20, color: colors.accent),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.completedToday,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: () => context.push(AppRoutes.reflection),
              child: Text(completed ? l10n.reflectAgainCta : l10n.reflectCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyContentCard extends StatelessWidget {
  const _EmptyContentCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(32),
        child: Center(
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
