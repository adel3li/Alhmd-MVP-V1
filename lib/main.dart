import 'dart:async';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/analytics/analytics_service.dart';
import 'core/notifications/notification_service_locator.dart';
import 'core/providers.dart';
import 'core/routing/router.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final analytics = await createAnalyticsService();
  final notifications = createNotificationService();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      analyticsServiceProvider.overrideWithValue(analytics),
      notificationServiceProvider.overrideWithValue(notifications),
    ],
  );

  await notifications.init(
    onTap: (payload) => _handleNotificationPayload(container, payload),
  );

  unawaited(_syncUserProperties(container));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AlhamdApp(),
    ),
  );

  // Cold start from a notification tap → deep-link to the reflection (§7.1).
  final launchPayload = await notifications.consumeLaunchPayload();
  if (launchPayload != null) {
    _handleNotificationPayload(container, launchPayload);
  }
}

void _handleNotificationPayload(ProviderContainer container, String payload) {
  if (payload != NotificationService.reflectionPayload) return;
  container.read(routerProvider).go(AppRoutes.reflection);
  unawaited(() async {
    final blessing = await container
        .read(contentRepositoryProvider)
        .blessingForDate(DateTime.now());
    if (blessing != null) {
      await container
          .read(analyticsServiceProvider)
          .notificationOpened(blessing.id);
    }
  }());
}

Future<void> _syncUserProperties(ProviderContainer container) async {
  final analytics = container.read(analyticsServiceProvider);
  final settings = container.read(settingsProvider);
  await analytics.setUserProperty('theme', switch (settings.themeMode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'auto',
  });
  await analytics.setUserProperty('text_size', settings.textSize.name);
  await analytics.setUserProperty(
    'notification_enabled',
    '${settings.notificationsEnabled}',
  );
}
