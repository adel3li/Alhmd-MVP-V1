import 'package:alhamd/data/db/app_database.dart';
import 'package:alhamd/data/repositories/journal_repository.dart';
import 'package:alhamd/features/reflection/reflection_flow_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/pump_until.dart';
import '../test/helpers/test_app.dart';

/// Golden-path E2E (§11.3): onboarding → home → full استشعار flow (fast
/// timers) → save journal entry → entry visible in سجل الحمد → consistency
/// grid shows today marked.
///
/// Runs on the real Drift store (the integration binding uses real async,
/// where drift streams behave normally). Notifications are stubbed
/// (deterministic across devices — no OS permission dialogs), so onboarding
/// shows its two content pages.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding through consistency', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final harness = await TestHarness.create(
      prefs: {},
      journal: JournalRepository(db),
    );
    addTearDown(harness.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    await tester.pumpWidget(
      harness.buildApp(
        extraOverrides: [
          reflectionSpeedProvider.overrideWithValue(0.01),
        ],
      ),
    );

    // Onboarding 1: logo + tagline.
    await pumpUntilFound(tester, find.text('ابدأ'));
    expect(find.textContaining('دقيقتان كل يوم'), findsWidgets);
    await tester.tap(find.text('ابدأ'));

    // Onboarding 2: استشعار القيمة explained, with the Quranic anchor.
    await pumpUntilFound(tester, find.text('فهمت'));
    await tester.tap(find.text('فهمت'));

    // Home.
    await pumpUntilFound(tester, find.text('استشعر النعمة'));
    expect(harness.analytics.eventNames, contains('onboarding_completed'));

    // Full reflection flow.
    await tester.tap(find.text('استشعر النعمة'));
    await pumpUntilFound(
      tester,
      find.widgetWithText(FilledButton, 'الحمد لله'),
      step: const Duration(milliseconds: 150),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'الحمد لله'));

    // Save a journal entry.
    await pumpUntilFound(tester, find.text('حفظ في سجل الحمد'));
    await tester.enterText(find.byType(TextField), 'الحمد لله حمدًا كثيرًا');
    await tester.tap(find.text('حفظ في سجل الحمد'));

    // Home shows the completed state.
    await pumpUntilFound(tester, find.text('حمدتَ اللهَ اليوم'));

    // Journal lists the entry.
    await tester.tap(find.text('سجل الحمد'));
    await pumpUntilFound(tester, find.text('الحمد لله حمدًا كثيرًا'));
    // pageBack() searches the English "Back" tooltip; under the ar locale
    // the Material back button must be tapped directly.
    await tester.tap(find.byType(BackButton));

    // Consistency marks today.
    final semantics = tester.ensureSemantics();
    await pumpUntilFound(tester, find.text('المداومة'));
    await tester.tap(find.text('المداومة'));
    await pumpUntilFound(tester, find.textContaining('لا سِباقَ مع أحد'));
    await pumpUntilFound(
      tester,
      find.bySemanticsLabel(RegExp('يومٌ حمدتَ اللهَ فيه')),
    );
    semantics.dispose();
  });
}
