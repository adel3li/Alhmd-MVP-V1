import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get blessingId => text()();
  TextColumn get blessingTitle => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('CompletionRow')
class Completions extends Table {
  /// Local-date key 'yyyy-MM-dd' — one completion per day (re-reflections
  /// update the row instead of inserting).
  TextColumn get dayKey => text()();
  TextColumn get blessingId => text()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get durationSec => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {dayKey};
}

@DriftDatabase(tables: [JournalEntries, Completions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // drift_flutter picks the right implementation per platform; on web it
    // loads sqlite3.wasm + drift_worker.js served from web/ (spec §2.1).
    return driftDatabase(
      name: 'alhamd',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
