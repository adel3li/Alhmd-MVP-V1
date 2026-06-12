/// Daily reminder abstraction — spec §7.
///
/// Mobile uses flutter_local_notifications; web is a no-op for MVP (§7.3 —
/// the home screen shows today's blessing prominently instead). UI copy is
/// passed in from l10n at the call site; the service holds no strings.
abstract class NotificationService {
  /// Payload carried by every daily reminder; tapping deep-links to the
  /// reflection flow (spec §7.1).
  static const String reflectionPayload = 'reflection';

  /// Whether this platform supports scheduled notifications.
  bool get isSupported;

  /// Initialize the plugin and timezone database. [onTap] receives the
  /// notification payload when the user taps a notification while the app
  /// is alive (foreground/background).
  Future<void> init({required void Function(String payload) onTap});

  /// If the app was cold-launched from a notification, returns its payload
  /// once (subsequent calls return null).
  Future<String?> consumeLaunchPayload();

  /// Requests the OS permission. Call only after the user picked a time —
  /// pre-permission pattern (spec §6.1).
  Future<bool> requestPermission();

  /// (Re)schedules the daily reminder at [hour]:[minute] local time.
  /// [bodies] is the rotating copy pool (§7.1); [title] the notification
  /// title. Replaces any previously scheduled reminders.
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required List<String> bodies,
    required String channelName,
    required String channelDescription,
  });

  Future<void> cancelAll();
}
