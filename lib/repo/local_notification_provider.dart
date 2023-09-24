import 'package:timezone/timezone.dart' as tz;

enum NotificationStatus {
  granted,
  denied,
  androidSettings,
  iOSSettings,
  unknown,
  notificationDueDateInPast,
}

abstract class LocalNotificationProvider {
  Future<bool?> init();

  Future<bool> isPermissionGranted();

  Future<NotificationStatus> checkPermission();

  Future<NotificationStatus> showNotification(
      int id, String title, String? body, tz.TZDateTime targetDateTime);

  Future<void> cancelNotification(int id);
}
