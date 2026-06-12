import 'package:alhamd/features/reflection/reflection_flow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_until.dart';
import '../helpers/test_app.dart';

/// Scrolls the HOME list (always the first Scrollable in the tree, even
/// when a route is pushed above it) until [finder]'s item is built, then
/// taps it. Only valid while home is the top route.
Future<void> _scrollToAndTap(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find.byType(Scrollable).first,
    const Offset(0, -120),
  );
  await tester.pump();
  await tester.tap(finder);
}

/// Brings an already-built widget (e.g. inside the reflection screen's own
/// SingleChildScrollView) into view via its enclosing scrollable, then taps.
Future<void> _ensureVisibleAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

/// The golden path (§11.3): home → complete a full استشعار flow with fast
/// timers → save a journal entry → entry visible in سجل الحمد → today is
/// marked in المداومة — all on the real router.
void main() {
  testWidgets('golden path: reflect → hamd → journal → consistency',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await TestHarness.create();
    addTearDown(harness.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    await tester.pumpWidget(
      harness.buildApp(
        extraOverrides: [
          // 10–20s steps become 100–200ms.
          reflectionSpeedProvider.overrideWithValue(0.01),
        ],
      ),
    );

    // Home.
    await pumpUntilFound(tester, find.text('استشعر النعمة'));
    await _scrollToAndTap(tester, find.text('استشعر النعمة'));

    // Flow: steps auto-advance on fast timers until the hamd button.
    await pumpUntilFound(
      tester,
      find.widgetWithText(FilledButton, 'الحمد لله'),
      step: const Duration(milliseconds: 150),
    );
    expect(harness.analytics.eventNames, contains('reflection_started'));
    await _ensureVisibleAndTap(
      tester,
      find.widgetWithText(FilledButton, 'الحمد لله'),
    );

    // Completion: journal prompt + optional text.
    await pumpUntilFound(tester, find.text('حفظ في سجل الحمد'));
    expect(harness.analytics.eventNames, contains('reflection_completed'));
    await tester.enterText(
      find.byType(TextField),
      'الحمد لله على نعمة لا أحصيها',
    );
    await _ensureVisibleAndTap(tester, find.text('حفظ في سجل الحمد'));

    // Back home: completed state.
    await pumpUntilFound(tester, find.text('حمدتَ اللهَ اليوم'));
    expect(harness.analytics.eventNames, contains('journal_entry_saved'));
    expect(
      harness.analytics.eventNames,
      isNot(contains('reflection_abandoned')),
    );
    await _scrollToAndTap(tester, find.text('أعد الاستشعار'));
    await pumpUntilFound(tester, find.text('خروج'));
    // Let the push transition finish so the exit tap lands on the settled
    // route, then wait for the flow overlay to fully pop away.
    await tester.pump(const Duration(milliseconds: 450));
    await tester.tap(find.text('خروج'));
    await pumpUntilGone(tester, find.text('خروج'));

    // Journal shows the saved entry.
    await pumpUntilFound(tester, find.text('سجل الحمد'));
    await _scrollToAndTap(tester, find.text('سجل الحمد'));
    await pumpUntilFound(tester, find.text('الحمد لله على نعمة لا أحصيها'));

    // Consistency grid marks today.
    final semantics = tester.ensureSemantics();
    // pageBack() searches the English "Back" tooltip; under the ar locale
    // the Material back button must be tapped directly.
    await tester.tap(find.byType(BackButton));
    await pumpUntilFound(tester, find.text('المداومة'));
    await _scrollToAndTap(tester, find.text('المداومة'));
    await pumpUntilFound(tester, find.textContaining('لا سِباقَ مع أحد'));
    await pumpUntilFound(
      tester,
      find.bySemanticsLabel(RegExp('يومٌ حمدتَ اللهَ فيه')),
    );
    semantics.dispose();

    // The step funnel fired for every step type (§8).
    final stepEvents = harness.analytics.events
        .where((e) => e.$1 == 'reflection_step_completed')
        .map((e) => e.$2!['step_type'])
        .toList();
    expect(
      stepEvents,
      containsAll(['ground', 'visualize', 'deepen', 'return', 'hamd']),
    );
  });

  testWidgets('quiet exit logs reflection_abandoned with the step',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await TestHarness.create();
    addTearDown(harness.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    await tester.pumpWidget(
      harness.buildApp(
        extraOverrides: [
          // Slow enough that the flow stays on step 1.
          reflectionSpeedProvider.overrideWithValue(10),
        ],
      ),
    );

    await pumpUntilFound(tester, find.text('استشعر النعمة'));
    await _scrollToAndTap(tester, find.text('استشعر النعمة'));
    await pumpUntilFound(tester, find.text('خروج'));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.tap(find.text('خروج'));
    await pumpUntilGone(tester, find.text('خروج'));
    await pumpUntilFound(tester, find.text('استشعر النعمة'));

    expect(harness.analytics.eventNames, contains('reflection_abandoned'));
    expect(
      harness.analytics.eventNames,
      isNot(contains('reflection_completed')),
    );
  });
}
