import 'package:flutter_test/flutter_test.dart';

/// Pumps frames until [finder] matches (or fails after [maxIterations]).
///
/// Used instead of pumpAndSettle because the app keeps gentle infinite
/// animations (breathing pulse, gradient drift) that never settle. Each
/// iteration also yields a slice of REAL time via [WidgetTester.runAsync]:
/// asset reads (rootBundle) complete on real IO outside the fake-async
/// zone, so fake-time pumps alone race against the disk.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  int maxIterations = 100,
}) async {
  for (var i = 0; i < maxIterations; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await tester.pump(step);
  }
  expect(finder, findsWidgets, reason: 'not found after $maxIterations pumps');
}

/// Pumps frames until [finder] no longer matches — e.g. waiting out a route
/// transition so taps can't land on a fading overlay.
Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  int maxIterations = 100,
}) async {
  for (var i = 0; i < maxIterations; i++) {
    if (finder.evaluate().isEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await tester.pump(step);
  }
  expect(finder, findsNothing, reason: 'still present after $maxIterations pumps');
}
