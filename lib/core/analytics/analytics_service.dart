import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Analytics abstraction — spec §8.
///
/// Events are snake_case, carry no PII, and journal content is NEVER sent.
/// Collection is disabled in debug builds (debug uses the logging impl).
abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);
  Future<void> setUserProperty(String name, String value);
}

/// Typed event helpers so call sites can't misspell event names (§8).
extension AnalyticsEvents on AnalyticsService {
  Future<void> onboardingCompleted({required bool notificationOptin}) =>
      logEvent('onboarding_completed', {
        'notification_optin': notificationOptin.toString(),
      });

  Future<void> dailyBlessingViewed(String blessingId, String category) =>
      logEvent('daily_blessing_viewed', {
        'blessing_id': blessingId,
        'category': category,
      });

  Future<void> reflectionStarted(String blessingId) =>
      logEvent('reflection_started', {'blessing_id': blessingId});

  Future<void> reflectionStepCompleted(
    String blessingId,
    int step,
    String stepType,
  ) =>
      logEvent('reflection_step_completed', {
        'blessing_id': blessingId,
        'step': step,
        'step_type': stepType,
      });

  /// The #1 product metric (§8).
  Future<void> reflectionCompleted(String blessingId, int durationSec) =>
      logEvent('reflection_completed', {
        'blessing_id': blessingId,
        'duration_sec': durationSec,
      });

  Future<void> reflectionAbandoned(String blessingId, int step) =>
      logEvent('reflection_abandoned', {
        'blessing_id': blessingId,
        'step': step,
      });

  Future<void> journalEntrySaved(String blessingId, {required bool hasText}) =>
      logEvent('journal_entry_saved', {
        'blessing_id': blessingId,
        'has_text': hasText.toString(),
      });

  Future<void> notificationOpened(String blessingId) =>
      logEvent('notification_opened', {'blessing_id': blessingId});

  Future<void> settingsChanged(String setting) =>
      logEvent('settings_changed', {'setting': setting});
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setUserProperty(String name, String value) =>
      _analytics.setUserProperty(name: name, value: value);
}

/// Debug builds: log locally, send nothing (§8).
class DebugAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    developer.log('$name ${parameters ?? {}}', name: 'analytics');
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    developer.log('user_property $name=$value', name: 'analytics');
  }
}

/// Release builds where Firebase isn't configured yet (no
/// firebase_options/google-services file): silently drop events. The app is
/// local-first and must never depend on analytics availability.
class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {}

  @override
  Future<void> setUserProperty(String name, String value) async {}
}

/// Picks the right implementation at startup.
///
/// To enable Firebase in release: run `flutterfire configure` (spec §10.1)
/// and pass the generated options to [Firebase.initializeApp] here.
Future<AnalyticsService> createAnalyticsService() async {
  if (kDebugMode) return DebugAnalyticsService();
  try {
    await Firebase.initializeApp();
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
    return FirebaseAnalyticsService(analytics);
  } catch (_) {
    return NoopAnalyticsService();
  }
}
