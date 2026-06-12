import 'notification_service.dart';
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart' as impl;

export 'notification_service.dart';

/// Selects the platform implementation at compile time: mobile gets
/// flutter_local_notifications, web gets the no-op (spec §4 rule 5, §7.3).
NotificationService createNotificationService() =>
    impl.createPlatformNotificationService();
