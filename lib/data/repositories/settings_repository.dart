import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show ThemeMode, TimeOfDay;
import 'package:shared_preferences/shared_preferences.dart';

/// Text size setting — «عادي / كبير» (spec §6.6).
enum AppTextSize {
  normal(1),
  large(1.2);

  const AppTextSize(this.scaleFactor);
  final double scaleFactor;
}

@immutable
class SettingsState {
  const SettingsState({
    required this.onboardingComplete,
    required this.themeMode,
    required this.textSize,
    required this.notificationsEnabled,
    required this.notificationMinutes,
  });

  final bool onboardingComplete;
  final ThemeMode themeMode;
  final AppTextSize textSize;
  final bool notificationsEnabled;

  /// Daily reminder time as minutes since midnight (default ٧:٠٠ صباحًا).
  final int notificationMinutes;

  TimeOfDay get notificationTime => TimeOfDay(
        hour: notificationMinutes ~/ 60,
        minute: notificationMinutes % 60,
      );

  SettingsState copyWith({
    bool? onboardingComplete,
    ThemeMode? themeMode,
    AppTextSize? textSize,
    bool? notificationsEnabled,
    int? notificationMinutes,
  }) {
    return SettingsState(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      themeMode: themeMode ?? this.themeMode,
      textSize: textSize ?? this.textSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationMinutes: notificationMinutes ?? this.notificationMinutes,
    );
  }
}

/// SharedPreferences-backed settings — spec §4 data sources.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboarding = 'onboarding_complete';
  static const _kThemeMode = 'theme_mode';
  static const _kTextSize = 'text_size';
  static const _kNotifEnabled = 'notifications_enabled';
  static const _kNotifMinutes = 'notification_minutes';

  static const int defaultNotificationMinutes = 7 * 60;

  SettingsState read() {
    return SettingsState(
      onboardingComplete: _prefs.getBool(_kOnboarding) ?? false,
      themeMode: switch (_prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      textSize: switch (_prefs.getString(_kTextSize)) {
        'large' => AppTextSize.large,
        _ => AppTextSize.normal,
      },
      notificationsEnabled: _prefs.getBool(_kNotifEnabled) ?? false,
      notificationMinutes:
          _prefs.getInt(_kNotifMinutes) ?? defaultNotificationMinutes,
    );
  }

  Future<void> write(SettingsState state) async {
    await _prefs.setBool(_kOnboarding, state.onboardingComplete);
    await _prefs.setString(_kThemeMode, switch (state.themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    await _prefs.setString(_kTextSize, switch (state.textSize) {
      AppTextSize.large => 'large',
      AppTextSize.normal => 'normal',
    });
    await _prefs.setBool(_kNotifEnabled, state.notificationsEnabled);
    await _prefs.setInt(_kNotifMinutes, state.notificationMinutes);
  }
}
