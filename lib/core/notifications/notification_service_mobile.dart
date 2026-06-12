import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../utils/time_math.dart';
import 'notification_service.dart';

/// Android & iOS implementation — spec §7.1/§7.2.
///
/// Schedules the next [scheduledDays] daily reminders individually (instead
/// of one repeating notification) so the copy rotates through the pool; the
/// schedule is refreshed on every app launch, which also self-heals after
/// timezone changes and device reboots.
class MobileNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int scheduledDays = 14;
  static const int _baseId = 100;
  static const String _channelId = 'daily_blessing';

  @override
  bool get isSupported => true;

  @override
  Future<void> init({required void Function(String payload) onTap}) async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep the default location; scheduling still works, §7.2 reschedule
      // on next launch will correct drift.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onTap(payload);
      },
    );
  }

  @override
  Future<String?> consumeLaunchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload;
    }
    return null;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required List<String> bodies,
    required String channelName,
    required String channelDescription,
  }) async {
    await cancelAll();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final now = DateTime.now();
    final first = nextDailyOccurrence(now, hour, minute);
    for (var i = 0; i < scheduledDays; i++) {
      final day = DateTime(
        first.year,
        first.month,
        first.day + i,
        hour,
        minute,
      );
      final scheduled = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        hour,
        minute,
      );
      await _plugin.zonedSchedule(
        id: _baseId + i,
        title: title,
        body: bodies[i % bodies.length],
        scheduledDate: scheduled,
        notificationDetails: details,
        // Inexact: a gentle daily nudge doesn't justify the Android 14+
        // exact-alarm permission friction.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: NotificationService.reflectionPayload,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}

NotificationService createPlatformNotificationService() =>
    MobileNotificationService();
