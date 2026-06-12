import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/arabic_digits.dart';
import '../../core/widgets/quran_verse_container.dart';
import '../../data/models/blessing.dart';
import '../../l10n/l10n.dart';
import '../settings/notification_copy.dart';
import '../settings/settings_controller.dart';

final _anchorVerseProvider = FutureProvider<QuranVerse?>(
  (ref) => ref.watch(contentRepositoryProvider).onboardingAnchorVerse(),
);

/// Onboarding — 3 screens, shown once (§6.1). On web the notification page
/// is omitted (§7.3) and the flow finishes after the second page.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);

  bool get _hasNotificationsPage =>
      ref.read(notificationServiceProvider).isSupported;

  int get _pageCount => _hasNotificationsPage ? 3 : 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page + 1 < _pageCount) {
      _pageController.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish(optIn: false);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  /// Request the OS permission only after the user picked a time —
  /// pre-permission pattern (§6.1).
  Future<void> _enableReminder() async {
    final granted =
        await ref.read(notificationServiceProvider).requestPermission();
    await _finish(optIn: granted);
  }

  Future<void> _finish({required bool optIn}) async {
    final copy = notificationCopyOf(context.l10n);
    await ref.read(settingsProvider.notifier).completeOnboarding(
          reminderTime: optIn ? _reminderTime : null,
          copy: copy,
        );
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.alhamd;

    final pages = <Widget>[
      _WelcomePage(onStart: _next),
      _IstisharPage(onUnderstood: _next),
      if (_hasNotificationsPage)
        _NotificationPage(
          time: _reminderTime,
          onPickTime: _pickTime,
          onEnable: _enableReminder,
          onSkip: () => _finish(optIn: false),
        ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 24, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pageCount; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsetsDirectional.symmetric(
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? colors.accent
                            : colors.textSecondary.withValues(alpha: 0.25),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    return Padding(
      padding: const EdgeInsetsDirectional.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.amiri,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          FilledButton(onPressed: onStart, child: Text(l10n.onboardingStart)),
        ],
      ),
    );
  }
}

class _IstisharPage extends ConsumerWidget {
  const _IstisharPage({required this.onUnderstood});

  final VoidCallback onUnderstood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final verse = ref.watch(_anchorVerseProvider).value;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.onboardingIstisharTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingIstisharBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (verse != null) QuranVerseContainer(verse: verse),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onUnderstood,
            child: Text(l10n.onboardingUnderstood),
          ),
        ],
      ),
    );
  }
}

class _NotificationPage extends StatelessWidget {
  const _NotificationPage({
    required this.time,
    required this.onPickTime,
    required this.onEnable,
    required this.onSkip,
  });

  final TimeOfDay time;
  final VoidCallback onPickTime;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    final timeLabel = toArabicDigits(
      MaterialLocalizations.of(context).formatTimeOfDay(time),
    );
    return Padding(
      padding: const EdgeInsetsDirectional.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingNotifTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          Center(
            child: OutlinedButton.icon(
              onPressed: onPickTime,
              icon: Icon(Icons.schedule, size: 20, color: colors.textPrimary),
              label: Text(
                '${l10n.onboardingPickTime}: $timeLabel',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: onEnable,
            child: Text(l10n.onboardingEnableReminder),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onSkip, child: Text(l10n.onboardingSkip)),
        ],
      ),
    );
  }
}
