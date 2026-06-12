import 'dart:io';

import 'package:alhamd/app.dart';
import 'package:alhamd/core/analytics/analytics_service.dart';
import 'package:alhamd/core/notifications/notification_service_stub.dart';
import 'package:alhamd/core/providers.dart';
import 'package:alhamd/core/theme/theme.dart';
import 'package:alhamd/data/repositories/content_repository.dart';
import 'package:alhamd/data/repositories/journal_repository.dart';
import 'package:alhamd/l10n/l10n.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, CachingAssetBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'in_memory_journal_store.dart';

/// Reads assets straight from the repository's file system with a
/// [SynchronousFuture]. rootBundle's platform-channel loads are unreliable
/// across sequential fake-async test zones (the cached future can belong to
/// a dead zone); this bundle has no zones and no IO races.
class FileSystemAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      SynchronousFuture(File(key).readAsStringSync());

  @override
  Future<ByteData> load(String key) =>
      SynchronousFuture(ByteData.sublistView(File(key).readAsBytesSync()));
}

/// Captures analytics events so tests can assert the §8 funnel.
class RecordingAnalyticsService implements AnalyticsService {
  final List<(String, Map<String, Object>?)> events = [];
  final Map<String, String> userProperties = {};

  List<String> get eventNames => [for (final e in events) e.$1];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    events.add((name, parameters));
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    userProperties[name] = value;
  }
}

/// A fixed «today» so tests are deterministic and no midnight timer is left
/// pending (the real currentDayProvider sleeps until midnight).
/// dayOfYear(2026-06-11) = 162 → 162 % 3 = 0 → blessing_001 in debug mode.
final testToday = DateTime(2026, 6, 11);

class TestHarness {
  TestHarness._(this.journal, this.analytics, this.overrides);

  final JournalStore journal;
  final RecordingAnalyticsService analytics;
  final List<Override> overrides;

  /// [journal] defaults to the in-memory store (drift streams don't survive
  /// the widget-test fake-async zone); the integration test passes a real
  /// Drift store instead.
  static Future<TestHarness> create({
    Map<String, Object> prefs = const {'onboarding_complete': true},
    DateTime? today,
    JournalStore? journal,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPrefs = await SharedPreferences.getInstance();
    final store = journal ?? InMemoryJournalStore();
    final analytics = RecordingAnalyticsService();
    final overrides = <Override>[
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      analyticsServiceProvider.overrideWithValue(analytics),
      notificationServiceProvider.overrideWithValue(NoopNotificationService()),
      journalRepositoryProvider.overrideWithValue(store),
      contentRepositoryProvider.overrideWith(
        (ref) => ContentRepository(bundle: FileSystemAssetBundle()),
      ),
      currentDayProvider.overrideWith(
        (ref) => Stream<DateTime>.value(today ?? testToday),
      ),
    ];
    return TestHarness._(store, analytics, overrides);
  }

  /// The full real app (router, theme, l10n, RTL) with test overrides.
  Widget buildApp({List<Override> extraOverrides = const []}) {
    return ProviderScope(
      overrides: [...overrides, ...extraOverrides],
      child: const AlhamdApp(),
    );
  }

  /// A single screen hosted in the app chrome (no router) for layout tests.
  Widget buildScreen(Widget child, {List<Override> extraOverrides = const []}) {
    return ProviderScope(
      overrides: [...overrides, ...extraOverrides],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        builder: (context, c) => Directionality(
          textDirection: TextDirection.rtl,
          child: c ?? const SizedBox.shrink(),
        ),
        home: child,
      ),
    );
  }

  Future<void> dispose() async {
    final store = journal;
    if (store is InMemoryJournalStore) await store.dispose();
  }
}
