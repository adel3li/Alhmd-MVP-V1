/// Domain models for the local journal («سجل الحمد») and the consistency
/// record («المداومة» — محاسبة النفس, never gamification).
library;

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.blessingId,
    required this.blessingTitle,
    required this.body,
    required this.createdAt,
  });

  final int id;
  final String blessingId;

  /// Snapshot of the blessing's shortTitle at write time, so journal cards
  /// stay correct even if content ordering changes later.
  final String blessingTitle;
  final String body;
  final DateTime createdAt;
}

class ReflectionCompletion {
  const ReflectionCompletion({
    required this.dayKey,
    required this.blessingId,
    required this.completedAt,
    this.durationSec,
  });

  /// Local-date key 'yyyy-MM-dd'.
  final String dayKey;
  final String blessingId;
  final DateTime completedAt;
  final int? durationSec;
}
