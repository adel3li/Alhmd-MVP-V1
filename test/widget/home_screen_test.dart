import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_until.dart';
import '../helpers/test_app.dart';

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find.byType(Scrollable).first,
    const Offset(0, -120),
  );
  await tester.pump();
}

void main() {
  // Spec §11.2: every screen renders under RTL + ar with no overflow at
  // 320 / 390 / 768 / 1280, and survives 1.3 text scale. Content below the
  // fold is reached by scrolling — only layout overflows are failures.
  const widths = [320.0, 390.0, 768.0, 1280.0];

  for (final width in widths) {
    testWidgets('home renders RTL without overflow at ${width.toInt()}',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      addTearDown(() => tester.pumpWidget(const SizedBox()));

      await tester.pumpWidget(harness.buildApp());
      await pumpUntilFound(tester, find.text('نعمة الإسلام'));

      expect(find.text('السلام عليكم'), findsOneWidget);

      // RTL is actually in force.
      final direction = Directionality.of(
        tester.element(find.text('السلام عليكم')),
      );
      expect(direction, TextDirection.rtl);

      // The Quran verse container renders with ornamental brackets.
      expect(find.textContaining('﴿'), findsWidgets);

      await _scrollTo(tester, find.text('استشعر النعمة'));
      expect(find.text('استشعر النعمة'), findsOneWidget);

      await _scrollTo(tester, find.text('سجل الحمد'));
      expect(find.text('سجل الحمد'), findsOneWidget);
      expect(find.text('المداومة'), findsOneWidget);
    });
  }

  testWidgets('home renders at 1.3 text scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final harness = await TestHarness.create();
    addTearDown(harness.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    await tester.pumpWidget(harness.buildApp());
    await pumpUntilFound(tester, find.text('نعمة الإسلام'));
    await _scrollTo(tester, find.text('استشعر النعمة'));
    expect(find.text('استشعر النعمة'), findsOneWidget);
  });

  testWidgets('daily_blessing_viewed is logged once', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await TestHarness.create();
    addTearDown(harness.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    await tester.pumpWidget(harness.buildApp());
    await pumpUntilFound(tester, find.text('نعمة الإسلام'));
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      harness.analytics.eventNames.where((e) => e == 'daily_blessing_viewed'),
      hasLength(1),
    );
  });
}
