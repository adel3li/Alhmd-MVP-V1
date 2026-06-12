import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/app_database.dart';
import '../data/models/blessing.dart';
import '../data/models/journal_entry.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/journal_repository.dart';
import '../data/repositories/settings_repository.dart';
import 'analytics/analytics_service.dart';
import 'notifications/notification_service_locator.dart';

/// Overridden in main() with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Overridden in main()'),
);

/// Overridden in main() with the implementation picked at startup.
final analyticsServiceProvider = Provider<AnalyticsService>(
  (_) => throw UnimplementedError('Overridden in main()'),
);

/// Overridden in main() with the platform implementation.
final notificationServiceProvider = Provider<NotificationService>(
  (_) => throw UnimplementedError('Overridden in main()'),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final contentRepositoryProvider =
    Provider<ContentRepository>((_) => ContentRepository());

final journalRepositoryProvider = Provider<JournalStore>(
  (ref) => JournalRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final contentDatabaseProvider = FutureProvider<ContentDatabase>(
  (ref) => ref.watch(contentRepositoryProvider).load(),
);

final publishedBlessingsProvider = FutureProvider<List<Blessing>>(
  (ref) => ref.watch(contentRepositoryProvider).published(),
);

/// Emits the current local date (midnight-truncated) and updates shortly
/// after midnight so «نعمة اليوم» rolls over without a restart (§11.4).
final currentDayProvider = StreamProvider<DateTime>((ref) async* {
  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  var current = today();
  yield current;
  while (true) {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    await Future<void>.delayed(
      nextMidnight.difference(now) + const Duration(seconds: 1),
    );
    final fresh = today();
    if (fresh != current) {
      current = fresh;
      yield current;
    }
  }
});

/// Deterministic «نعمة اليوم» — same blessing for all users on a given date.
final blessingOfDayProvider = FutureProvider<Blessing?>((ref) async {
  final day = ref.watch(currentDayProvider).value ?? DateTime.now();
  final published = await ref.watch(publishedBlessingsProvider.future);
  return ContentRepository.selectForDate(published, day);
});

final journalEntriesProvider = StreamProvider<List<JournalEntry>>(
  (ref) => ref.watch(journalRepositoryProvider).watchEntries(),
);

final completionsProvider = StreamProvider<List<ReflectionCompletion>>(
  (ref) => ref.watch(journalRepositoryProvider).watchCompletions(),
);

/// Whether today's reflection is completed (drives the Home card state).
final todayCompletedProvider = StreamProvider<bool>((ref) {
  final day = ref.watch(currentDayProvider).value ?? DateTime.now();
  return ref.watch(journalRepositoryProvider).watchCompletedOn(day);
});
