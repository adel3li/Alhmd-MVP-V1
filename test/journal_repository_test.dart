import 'package:alhamd/data/db/app_database.dart';
import 'package:alhamd/data/repositories/journal_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late JournalRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = JournalRepository(db);
  });

  tearDown(() => db.close());

  test('dayKeyFor pads month and day', () {
    expect(JournalRepository.dayKeyFor(DateTime(2026, 6, 1)), '2026-06-01');
    expect(JournalRepository.dayKeyFor(DateTime(2026, 11, 25)), '2026-11-25');
  });

  test('add, watch (reverse-chronological), delete', () async {
    await repo.addEntry(
      blessingId: 'b1',
      blessingTitle: 'الإسلام',
      body: 'أول تدوين',
      createdAt: DateTime(2026, 6, 1, 8),
    );
    await repo.addEntry(
      blessingId: 'b2',
      blessingTitle: 'الماء',
      body: 'ثاني تدوين',
      createdAt: DateTime(2026, 6, 2, 8),
    );

    var entries = await repo.watchEntries().first;
    expect(entries.length, 2);
    expect(entries.first.body, 'ثاني تدوين', reason: 'newest first');
    expect(entries.last.blessingTitle, 'الإسلام');

    await repo.deleteEntry(entries.first.id);
    entries = await repo.watchEntries().first;
    expect(entries.length, 1);
    expect(entries.single.body, 'أول تدوين');
  });

  test('empty body entries are allowed (completion without text)', () async {
    await repo.addEntry(blessingId: 'b1', blessingTitle: 'الإسلام', body: '');
    final entries = await repo.watchEntries().first;
    expect(entries.single.body, isEmpty);
  });

  test('recordCompletion is idempotent per day (re-reflection updates)',
      () async {
    final morning = DateTime(2026, 6, 11, 7, 30);
    final evening = DateTime(2026, 6, 11, 21, 0);
    await repo.recordCompletion(
      date: morning,
      blessingId: 'b1',
      durationSec: 80,
    );
    await repo.recordCompletion(
      date: evening,
      blessingId: 'b1',
      durationSec: 95,
    );

    final completions = await repo.watchCompletions().first;
    expect(completions.length, 1);
    expect(completions.single.dayKey, '2026-06-11');
    expect(completions.single.durationSec, 95);
  });

  test('watchCompletedOn reflects only the given day', () async {
    await repo.recordCompletion(
      date: DateTime(2026, 6, 11, 7),
      blessingId: 'b1',
    );
    expect(await repo.watchCompletedOn(DateTime(2026, 6, 11, 23)).first, true);
    expect(await repo.watchCompletedOn(DateTime(2026, 6, 12)).first, false);
  });
}
