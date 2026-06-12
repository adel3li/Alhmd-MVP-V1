import 'package:flutter/material.dart' show ThemeMode, TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/providers.dart';
import '../../data/repositories/settings_repository.dart';

/// Notification copy built from l10n at the call site (the service and
/// controller hold no user-facing strings — spec §4 rule 2).
class NotificationCopy {
  const NotificationCopy({
    required this.title,
    required this.bodies,
    required this.channelName,
    required this.channelDescription,
  });

  final String title;
  final List<String> bodies;
  final String channelName;
  final String channelDescription;
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() => ref.read(settingsRepositoryProvider).read();

  Future<void> _persist() => ref.read(settingsRepositoryProvider).write(state);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
    await _analytics.settingsChanged('theme');
    await _analytics.setUserProperty('theme', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'auto',
    });
  }

  Future<void> setTextSize(AppTextSize size) async {
    state = state.copyWith(textSize: size);
    await _persist();
    await _analytics.settingsChanged('text_size');
    await _analytics.setUserProperty('text_size', size.name);
  }

  Future<void> setNotificationTime(TimeOfDay time, NotificationCopy copy) async {
    state = state.copyWith(
      notificationMinutes: time.hour * 60 + time.minute,
      notificationsEnabled: true,
    );
    await _persist();
    await rescheduleNotifications(copy);
    await _analytics.settingsChanged('notification_time');
    await _analytics.setUserProperty('notification_enabled', 'true');
  }

  Future<void> setNotificationsEnabled(
    bool enabled,
    NotificationCopy copy,
  ) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _persist();
    if (enabled) {
      await rescheduleNotifications(copy);
    } else {
      await ref.read(notificationServiceProvider).cancelAll();
    }
    await _analytics.settingsChanged('notifications_enabled');
    await _analytics.setUserProperty('notification_enabled', '$enabled');
  }

  /// Completes onboarding. [reminderTime] is non-null when the user picked a
  /// time AND the OS permission was granted.
  Future<void> completeOnboarding({
    TimeOfDay? reminderTime,
    NotificationCopy? copy,
  }) async {
    final optedIn = reminderTime != null;
    state = state.copyWith(
      onboardingComplete: true,
      notificationsEnabled: optedIn,
      notificationMinutes: optedIn
          ? reminderTime.hour * 60 + reminderTime.minute
          : state.notificationMinutes,
    );
    await _persist();
    if (optedIn && copy != null) {
      await rescheduleNotifications(copy);
    }
    await _analytics.onboardingCompleted(notificationOptin: optedIn);
    await _analytics.setUserProperty('notification_enabled', '$optedIn');
  }

  /// (Re)schedules the next batch of daily reminders. Called after any
  /// notification setting changes and on every app launch (§7.2 self-heal).
  Future<void> rescheduleNotifications(NotificationCopy copy) async {
    final service = ref.read(notificationServiceProvider);
    if (!service.isSupported || !state.notificationsEnabled) return;
    final time = state.notificationTime;
    await service.scheduleDaily(
      hour: time.hour,
      minute: time.minute,
      title: copy.title,
      bodies: copy.bodies,
      channelName: copy.channelName,
      channelDescription: copy.channelDescription,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
