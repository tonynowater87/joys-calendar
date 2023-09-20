enum NotificationStatus { granted, denied, androidSettings, iOSSettings,unknown }

abstract class LocalNotificationProvider {
  Future<bool?> init();

  Future<NotificationStatus> showNotification(int id, String title, String body);

  Future<void> cancelNotification(int id);
}
