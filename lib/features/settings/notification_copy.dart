import '../../l10n/l10n.dart';
import 'settings_controller.dart';

/// Builds the daily-reminder copy from l10n (§7.1 rotating pool). The
/// Quranic phrase in the pool comes from the spec-defined notification copy.
NotificationCopy notificationCopyOf(AppLocalizations l10n) {
  return NotificationCopy(
    title: l10n.appTitle,
    bodies: [l10n.notifBody1, l10n.notifBody2, l10n.notifBody3],
    channelName: l10n.notifChannelName,
    channelDescription: l10n.notifChannelDesc,
  );
}
