abstract class LocalNotificationProvider {
  Future<bool?> init();

  Future<void> showNotification(int id, String title, String body);

  Future<void> cancelNotification(int id);
}
