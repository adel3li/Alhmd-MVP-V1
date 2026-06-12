import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/theme.dart';
import '../../data/models/blessing.dart';
import '../../l10n/l10n.dart';

/// Speed multiplier for step pacing — overridden in tests so the flow can be
/// driven without waiting out real durations (§11.3).
final reflectionSpeedProvider = Provider<double>((_) => 1);

/// استشعار القيمة — the core guided loss-visualization flow (§6.3).
///
/// Full-screen and immersive: always the dark «سكينة» palette regardless of
/// app theme, slow breathing motion, one step at a time. Steps auto-advance
/// after their duration; «التالي» is offered only outside the visualization
/// deep (steps typed visualize/deepen never show a skip — only the quiet
/// «خروج» exit remains).
class ReflectionFlowScreen extends ConsumerStatefulWidget {
  const ReflectionFlowScreen({super.key});

  @override
  ConsumerState<ReflectionFlowScreen> createState() =>
      _ReflectionFlowScreenState();
}

class _ReflectionFlowScreenState extends ConsumerState<ReflectionFlowScreen>
    with TickerProviderStateMixin {
  Blessing? _blessing;
  int _stepIndex = 0;
  bool _completionPhase = false;
  bool _flowCompleted = false;
  bool _abandonLogged = false;
  DateTime? _startedAt;

  late final AnimationController _stepController;
  late final AnimationController _breathController;
  late final AnimationController _backgroundController;
  final TextEditingController _journalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addStatusListener(_onStepStatus);
    // The slow-pulse "breathing" scale: 1.0 → 1.03 over a 4s cycle (§3.4).
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _stepController.dispose();
    _breathController.dispose();
    _backgroundController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  void _start(Blessing blessing) {
    if (_blessing != null) return;
    _blessing = blessing;
    _startedAt = DateTime.now();
    Future<void>.microtask(
      () => ref.read(analyticsServiceProvider).reflectionStarted(blessing.id),
    );
    _runStep(0);
  }

  IstisharStep get _currentStep => _blessing!.istisharSteps[_stepIndex];

  void _runStep(int index) {
    final blessing = _blessing!;
    final speed = ref.read(reflectionSpeedProvider);
    final step = blessing.istisharSteps[index];
    setState(() => _stepIndex = index);
    _stepController
      ..duration = Duration(
        milliseconds: math.max(50, (step.durationSec * 1000 * speed).round()),
      )
      ..value = 0
      ..forward();
  }

  void _onStepStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _blessing == null) return;
    // The hamd step holds — completion happens through the «الحمد لله»
    // button, never by timeout.
    if (_currentStep.type == IstisharStepType.hamd) return;
    _advance();
  }

  void _advance() {
    final blessing = _blessing;
    if (blessing == null || _completionPhase) return;
    final step = _currentStep;
    Future<void>.microtask(
      () => ref
          .read(analyticsServiceProvider)
          .reflectionStepCompleted(blessing.id, step.step, step.type.jsonValue),
    );
    if (_stepIndex + 1 < blessing.istisharSteps.length) {
      // Soft haptic tick on step change (mobile; harmless no-op on web).
      unawaited(HapticFeedback.selectionClick());
      _runStep(_stepIndex + 1);
    }
  }

  Future<void> _onHamdPressed() async {
    final blessing = _blessing;
    if (blessing == null || _flowCompleted) return;
    _flowCompleted = true;
    final step = _currentStep;
    final analytics = ref.read(analyticsServiceProvider);
    final durationSec =
        DateTime.now().difference(_startedAt ?? DateTime.now()).inSeconds;
    // The completion belongs to the app's «اليوم» (the day whose blessing
    // was reflected on), so the record stays consistent with نعمة اليوم
    // across the midnight rollover.
    final day = ref.read(currentDayProvider).value ?? DateTime.now();
    _stepController.stop();
    setState(() => _completionPhase = true);
    await analytics.reflectionStepCompleted(
      blessing.id,
      step.step,
      step.type.jsonValue,
    );
    await ref.read(journalRepositoryProvider).recordCompletion(
          date: day,
          blessingId: blessing.id,
          durationSec: durationSec,
        );
    await analytics.reflectionCompleted(blessing.id, durationSec);
  }

  Future<void> _saveJournal() async {
    final blessing = _blessing;
    if (blessing == null) return;
    final text = _journalController.text.trim();
    await ref.read(journalRepositoryProvider).addEntry(
          blessingId: blessing.id,
          blessingTitle: blessing.shortTitle,
          body: text,
        );
    await ref
        .read(analyticsServiceProvider)
        .journalEntrySaved(blessing.id, hasText: text.isNotEmpty);
    if (mounted) _leave();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _logAbandonIfNeeded() {
    final blessing = _blessing;
    if (blessing == null || _flowCompleted || _abandonLogged) return;
    _abandonLogged = true;
    final step = blessing.istisharSteps[_stepIndex].step;
    Future<void>.microtask(
      () => ref
          .read(analyticsServiceProvider)
          .reflectionAbandoned(blessing.id, step),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blessingAsync = ref.watch(blessingOfDayProvider);
    final darkTheme = AppTheme.dark();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _logAbandonIfNeeded();
      },
      child: Theme(
        data: darkTheme,
        child: Scaffold(
          backgroundColor: AppColorsDark.background,
          body: blessingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _NoContentView(onExit: _leave),
            data: (blessing) {
              if (blessing == null) return _NoContentView(onExit: _leave);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _start(blessing),
              );
              if (_blessing == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildFlow(context, darkTheme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFlow(BuildContext context, ThemeData theme) {
    final step = _currentStep;
    final isReturnOrHamd = step.type == IstisharStepType.returnStep ||
        step.type == IstisharStepType.hamd;

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final t = _backgroundController.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              // Very slow radial gradient drift (§6.3).
              center: Alignment(0.3 - 0.6 * t, -0.4 + 0.25 * t),
              radius: 1.6,
              colors: const [Color(0xFF1C2540), Color(0xFF12182A)],
            ),
          ),
          child: child,
        );
      },
      child: AnimatedContainer(
        // `return`: brightness gently rises (§6.3).
        duration: const Duration(milliseconds: 800),
        color: _completionPhase || isReturnOrHamd
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              if (!_completionPhase)
                PositionedDirectional(
                  top: 4,
                  start: 4,
                  child: TextButton(
                    onPressed: _leave,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColorsDark.textSecondary,
                    ),
                    child: Text(context.l10n.reflectionExit),
                  ),
                ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 28,
                    vertical: 56,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: _completionPhase
                        ? _CompletionView(
                            key: const ValueKey('completion'),
                            blessing: _blessing!,
                            journalController: _journalController,
                            onSave: _saveJournal,
                            onLater: _leave,
                          )
                        : _StepView(
                            key: ValueKey('step$_stepIndex'),
                            step: step,
                            blessing: _blessing!,
                            breath: _breathController,
                            progress: _stepController,
                            onNext: _advance,
                            onHamd: _onHamdPressed,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoContentView extends StatelessWidget {
  const _NoContentView({required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.noContentAvailable,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onExit, child: Text(context.l10n.commonClose)),
        ],
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({
    required this.step,
    required this.blessing,
    required this.breath,
    required this.progress,
    required this.onNext,
    required this.onHamd,
    super.key,
  });

  final IstisharStep step;
  final Blessing blessing;
  final Animation<double> breath;
  final Animation<double> progress;
  final VoidCallback onNext;
  final VoidCallback onHamd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isHamd = step.type == IstisharStepType.hamd;
    final dimmed = step.type == IstisharStepType.visualize ||
        step.type == IstisharStepType.deepen;
    // Steps render in IBM Plex Arabic; the hamd step in Amiri (§6.3).
    final textStyle = isHamd
        ? AppTypography.hadith.copyWith(
            color: AppColorsDark.textPrimary,
            fontSize: 26,
          )
        : theme.textTheme.bodyLarge!.copyWith(
            fontSize: 22,
            height: 1.9,
            color: AppColorsDark.textPrimary
                .withValues(alpha: dimmed ? 0.82 : 1),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (step.type == IstisharStepType.ground)
          _BreathingCircle(breath: breath),
        if (isHamd) _GoldBloom(breath: breath),
        const SizedBox(height: 28),
        Text(step.text, textAlign: TextAlign.center, style: textStyle),
        if (isHamd && blessing.duaa != null) ...[
          const SizedBox(height: 20),
          Text(
            blessing.duaa!,
            textAlign: TextAlign.center,
            style: AppTypography.hadith.copyWith(
              fontSize: 19,
              color: AppColorsDark.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 40),
        if (isHamd)
          FilledButton(
            onPressed: onHamd,
            style: FilledButton.styleFrom(
              minimumSize: const Size(220, 56),
            ),
            child: Text(l10n.hamdButton),
          )
        else
          _ProgressArc(
            progress: progress,
            // Skip is deliberately absent mid-visualization (§6.3): only
            // ground/return steps offer «التالي».
            child: dimmed
                ? null
                : TextButton(
                    onPressed: onNext,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColorsDark.textSecondary,
                    ),
                    child: Text(l10n.reflectionNext),
                  ),
          ),
      ],
    );
  }
}

class _BreathingCircle extends StatelessWidget {
  const _BreathingCircle({required this.breath});

  final Animation<double> breath;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breath,
      builder: (context, _) {
        final scale = 1.0 + 0.03 * breath.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColorsDark.accent.withValues(alpha: 0.22),
                  AppColorsDark.accent.withValues(alpha: 0.02),
                ],
              ),
              border: Border.all(
                color: AppColorsDark.accent.withValues(alpha: 0.35),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gold accents bloom on the hamd step (§6.3) — quiet glow, no confetti.
class _GoldBloom extends StatelessWidget {
  const _GoldBloom({required this.breath});

  final Animation<double> breath;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breath,
      builder: (context, _) {
        final alpha = 0.25 + 0.12 * breath.value;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColorsDark.accent.withValues(alpha: alpha),
                AppColorsDark.accent.withValues(alpha: 0.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Thin gold arc showing the auto-advance progress of the current step.
class _ProgressArc extends StatelessWidget {
  const _ProgressArc({required this.progress, this.child});

  final Animation<double> progress;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return CustomPaint(
          painter: _ArcPainter(progress.value),
          child: SizedBox(
            width: 96,
            height: 96,
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColorsDark.accent.withValues(alpha: 0.18);
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = AppColorsDark.accent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Completion: quiet gold glow, «الحمد لله» fading in, then the journal
/// prompt with an optional text field (§6.3, §3.4).
class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.blessing,
    required this.journalController,
    required this.onSave,
    required this.onLater,
    super.key,
  });

  final Blessing blessing;
  final TextEditingController journalController;
  final VoidCallback onSave;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeIn,
          builder: (context, value, child) =>
              Opacity(opacity: value, child: child),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColorsDark.accent.withValues(alpha: 0.35),
                      AppColorsDark.accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 36,
                  color: AppColorsDark.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hamdButton,
                style: AppTypography.blessingTitle.copyWith(
                  color: AppColorsDark.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (blessing.journalPrompt != null)
          Text(
            blessing.journalPrompt!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        const SizedBox(height: 16),
        TextField(
          controller: journalController,
          minLines: 3,
          maxLines: 6,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(hintText: l10n.completionWriteHint),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: onSave, child: Text(l10n.saveToJournal)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onLater,
          style: TextButton.styleFrom(
            foregroundColor: AppColorsDark.textSecondary,
          ),
          child: Text(l10n.later),
        ),
      ],
    );
  }
}
