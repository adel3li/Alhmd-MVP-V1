import 'notification_service.dart';

/// Web (and any unsupported platform): scheduled notifications are not
/// available without a push backend — spec §7.3. All methods are no-ops.
class NoopNotificationService implements NotificationService {
  @override
  bool get isSupported => false;

  @override
  Future<void> init({required void Function(String payload) onTap}) async {}

  @override
  Future<String?> consumeLaunchPayload() async => null;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required List<String> bodies,
    required String channelName,
    required String channelDescription,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}

NotificationService createPlatformNotificationService() =>
    NoopNotificationService();
