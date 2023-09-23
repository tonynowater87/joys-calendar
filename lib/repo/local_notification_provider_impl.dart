import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:timezone/timezone.dart' as tz;

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
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
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

  // TODO 帶入時間
  // cancel first with same id
  @override
  Future<NotificationStatus> showNotification(
      int id, String title, String body) async {
    var remindDate =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30));

    if (Platform.isAndroid) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('我的記事頻道ID', '我的記事提醒',
              channelDescription: '',
              importance: Importance.max,
              visibility: NotificationVisibility.secret,
              priority: Priority.high);
      //_flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, scheduledDate, notificationDetails, uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation)
      /*_ensureInitialized().then((value) =>
          _flutterLocalNotificationsPlugin.show(id, title, body,
              const NotificationDetails(android: androidNotificationDetails),
              payload: null));*/
      var isInit = await _ensureInitialized();
      debugPrint('[Tony] isInit: $isInit');

      var areNotificationsEnabled = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .areNotificationsEnabled();

      debugPrint('[Tony] Android areNotificationsEnabled: $areNotificationsEnabled');

      bool? permissionRequestResult;

      if (areNotificationsEnabled == false || areNotificationsEnabled == null) {
        // TODO Android 13 permission 若false，則有可能是拒絕或是已不詢問(需跳對話框提示轉至設定頁面)
        permissionRequestResult = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .requestPermission();
      }

      debugPrint('[Tony] Android permissionRequestResult: $permissionRequestResult');

      if (areNotificationsEnabled == false &&
          permissionRequestResult == false) {
        return Future.value(NotificationStatus.androidSettings);
      }

      return _flutterLocalNotificationsPlugin
          .zonedSchedule(id, title, body, remindDate,
              const NotificationDetails(android: androidNotificationDetails),
              androidScheduleMode: AndroidScheduleMode.exact,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime)
          .then((value) => NotificationStatus.granted);
    } else if (Platform.isIOS) {
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(threadIdentifier: 'joys_calendar');

      var isInit = await _ensureInitialized();
      debugPrint('[Tony] iOS isInit: $isInit');

      var permissionRequestResult = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(alert: true, badge: true, sound: true);

      print('[Tony] iOS permissionRequestResult: $permissionRequestResult');

      if (permissionRequestResult == false) {
        // TODO iOS 需跳對話框提示轉至設定頁面
        return Future.value(NotificationStatus.iOSSettings);
      }

      return _flutterLocalNotificationsPlugin
          .zonedSchedule(id, title, body, remindDate,
              const NotificationDetails(iOS: iOSPlatformChannelSpecifics),
              androidScheduleMode: AndroidScheduleMode.exact,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime)
          .then((value) => NotificationStatus.granted);
    } else {
      return Future.value(NotificationStatus.unknown);
    }
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
        return Future.value(false);
      }
    });
  }
}
