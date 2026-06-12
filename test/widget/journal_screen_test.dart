import 'package:alhamd/features/journal/journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_until.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('journal shows the gentle empty state', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await TestHarness.create();
    addTearDown(harness.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    await tester.pumpWidget(harness.buildScreen(const JournalScreen()));
    await pumpUntilFound(tester, find.textContaining('صفحةً بيضاء'));
    expect(find.text('استشعر نعمة اليوم'), findsOneWidget);
  });

  testWidgets('journal lists entries newest-first with delete confirm',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await TestHarness.create();
    addTearDown(harness.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    final repo = harness.journal;
    await repo.addEntry(
      blessingId: 'b1',
      blessingTitle: 'الإسلام',
      body: 'تدوين أقدم',
      createdAt: DateTime(2026, 6, 1),
    );
    await repo.addEntry(
      blessingId: 'b2',
      blessingTitle: 'الماء',
      body: 'تدوين أحدث',
      createdAt: DateTime(2026, 6, 2),
    );

    await tester.pumpWidget(harness.buildScreen(const JournalScreen()));
    await pumpUntilFound(tester, find.text('تدوين أحدث'));
    expect(find.text('تدوين أقدم'), findsOneWidget);

    // Newest entry appears above the older one.
    final newerY = tester.getTopLeft(find.text('تدوين أحدث')).dy;
    final olderY = tester.getTopLeft(find.text('تدوين أقدم')).dy;
    expect(newerY, lessThan(olderY));

    // Long-press → confirm dialog → delete.
    await tester.longPress(find.text('تدوين أحدث'));
    await pumpUntilFound(tester, find.text('حذف'));
    await tester.tap(find.text('حذف'));
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntilFound(tester, find.text('تدوين أقدم'));
    expect(find.text('تدوين أحدث'), findsNothing);
  });
}
