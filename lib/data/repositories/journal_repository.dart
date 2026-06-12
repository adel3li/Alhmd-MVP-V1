import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/journal_entry.dart';

/// Local-date key 'yyyy-MM-dd' used by the completion record and the
/// consistency grid.
String journalDayKey(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

/// Journal + completion store — spec §6.4/§6.5. Implemented by Drift in the
/// app; widget tests substitute an in-memory implementation (the repository
/// boundary from spec §4).
abstract interface class JournalStore {
  Stream<List<JournalEntry>> watchEntries();

  Future<int> addEntry({
    required String blessingId,
    required String blessingTitle,
    required String body,
    DateTime? createdAt,
  });

  Future<void> deleteEntry(int id);

  /// Records that the استشعار flow was completed on [date]. One row per day:
  /// repeating the reflection the same day updates the row.
  Future<void> recordCompletion({
    required DateTime date,
    required String blessingId,
    int? durationSec,
  });

  Stream<List<ReflectionCompletion>> watchCompletions();

  Stream<bool> watchCompletedOn(DateTime date);
}

/// Drift/SQLite implementation — local-only, journal content never leaves
/// the device.
class JournalRepository implements JournalStore {
  JournalRepository(this._db);

  final AppDatabase _db;

  /// Kept for callers that already use the repository as their day-key
  /// source; delegates to [journalDayKey].
  static String dayKeyFor(DateTime date) => journalDayKey(date);

  @override
  Stream<List<JournalEntry>> watchEntries() {
    final query = _db.select(_db.journalEntries)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => JournalEntry(
                  id: r.id,
                  blessingId: r.blessingId,
                  blessingTitle: r.blessingTitle,
                  body: r.body,
                  createdAt: r.createdAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<int> addEntry({
    required String blessingId,
    required String blessingTitle,
    required String body,
    DateTime? createdAt,
  }) {
    return _db.into(_db.journalEntries).insert(
          JournalEntriesCompanion.insert(
            blessingId: blessingId,
            blessingTitle: blessingTitle,
            body: body,
            createdAt: createdAt ?? DateTime.now(),
          ),
        );
  }

  @override
  Future<void> deleteEntry(int id) async {
    await (_db.delete(_db.journalEntries)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> recordCompletion({
    required DateTime date,
    required String blessingId,
    int? durationSec,
  }) {
    return _db.into(_db.completions).insertOnConflictUpdate(
          CompletionsCompanion.insert(
            dayKey: journalDayKey(date),
            blessingId: blessingId,
            completedAt: date,
            durationSec: Value(durationSec),
          ),
        );
  }

  @override
  Stream<List<ReflectionCompletion>> watchCompletions() {
    return _db.select(_db.completions).watch().map(
          (rows) => rows
              .map(
                (r) => ReflectionCompletion(
                  dayKey: r.dayKey,
                  blessingId: r.blessingId,
                  completedAt: r.completedAt,
                  durationSec: r.durationSec,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<bool> watchCompletedOn(DateTime date) {
    final key = journalDayKey(date);
    final query = _db.select(_db.completions)
      ..where((t) => t.dayKey.equals(key));
    return query.watch().map((rows) => rows.isNotEmpty);
  }
}
