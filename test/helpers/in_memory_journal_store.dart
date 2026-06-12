import 'dart:async';

import 'package:alhamd/data/models/journal_entry.dart';
import 'package:alhamd/data/repositories/journal_repository.dart';

/// In-memory [JournalStore] for widget tests.
///
/// Drift's stream machinery captures the test's fake-async zone and wedges
/// the runner (timers that nothing pumps); widget tests therefore run on
/// this implementation, while the Drift one is covered by the real-async
/// unit tests (journal_repository_test.dart) and the integration test.
class InMemoryJournalStore implements JournalStore {
  final List<JournalEntry> _entries = [];
  final Map<String, ReflectionCompletion> _completions = {};
  final StreamController<void> _changes = StreamController.broadcast();
  int _nextId = 1;

  List<JournalEntry> _sortedEntries() {
    final copy = [..._entries]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  Stream<T> _watch<T>(T Function() snapshot) {
    return Stream<T>.multi((controller) {
      controller.add(snapshot());
      final sub = _changes.stream.listen((_) => controller.add(snapshot()));
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Stream<List<JournalEntry>> watchEntries() => _watch(_sortedEntries);

  @override
  Future<int> addEntry({
    required String blessingId,
    required String blessingTitle,
    required String body,
    DateTime? createdAt,
  }) async {
    final id = _nextId++;
    _entries.add(
      JournalEntry(
        id: id,
        blessingId: blessingId,
        blessingTitle: blessingTitle,
        body: body,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );
    _changes.add(null);
    return id;
  }

  @override
  Future<void> deleteEntry(int id) async {
    _entries.removeWhere((e) => e.id == id);
    _changes.add(null);
  }

  @override
  Future<void> recordCompletion({
    required DateTime date,
    required String blessingId,
    int? durationSec,
  }) async {
    final key = journalDayKey(date);
    _completions[key] = ReflectionCompletion(
      dayKey: key,
      blessingId: blessingId,
      completedAt: date,
      durationSec: durationSec,
    );
    _changes.add(null);
  }

  @override
  Stream<List<ReflectionCompletion>> watchCompletions() =>
      _watch(() => _completions.values.toList());

  @override
  Stream<bool> watchCompletedOn(DateTime date) {
    final key = journalDayKey(date);
    return _watch(() => _completions.containsKey(key));
  }

  Future<void> dispose() => _changes.close();
}
