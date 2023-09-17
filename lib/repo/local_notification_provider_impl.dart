import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';

class LocalNotificationProviderImpl implements LocalNotificationProvider {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var _isInitialized = false;

  LocalNotificationProviderImpl();

  @override
  Future<void> cancelNotification(int id) async {
    _ensureInitialized()
        .then((value) => _flutterLocalNotificationsPlugin.cancel(id));
  }

  @override
  Future<bool?> init() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    onDidReceiveLocalNotification(
        int id, String? title, String? body, String? payload) {}

    onDidReceiveNotificationResponse(notificationDetail) {}

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: null,
            linux: null);
    return _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  @override
  Future<void> showNotification(int id, String title, String body) async {
    if (Platform.isAndroid) {
      // TODO Android 13 permission
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('我的記事頻道ID', '我的記事提醒',
              channelDescription: '',
              importance: Importance.max,
              visibility: NotificationVisibility.secret,
              priority: Priority.high);
      //_flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, scheduledDate, notificationDetails, uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation)
      _ensureInitialized().then((value) =>
          _flutterLocalNotificationsPlugin.show(id, title, body,
              const NotificationDetails(android: androidNotificationDetails),
              payload: null));
    } else if (Platform.isIOS) {
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(threadIdentifier: 'joys_calendar');
      _ensureInitialized().then((value) =>
          _flutterLocalNotificationsPlugin.show(id, title, body,
              const NotificationDetails(iOS: iOSPlatformChannelSpecifics)));
    } else {}
  }

  Future<bool> _ensureInitialized() {
    if (_isInitialized) {
      return Future.value(true);
    }
    return init().then((value) {
      if (value == true) {
        debugPrint('[Tony] Local notification initialized');
        _isInitialized = true;
        return Future.value(true);
      } else {
        return Future.error(
            'Failed to initialize local notification, result = $value');
      }
    });
  }
}
