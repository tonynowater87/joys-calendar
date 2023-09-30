import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationProviderImpl implements LocalNotificationProvider {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var _isInitialized = false;

  late SharedPreferenceProvider sharedPreferenceProvider;

  LocalNotificationProviderImpl({required this.sharedPreferenceProvider});

  @override
  Future<void> cancelNotification(int id) async {
    debugPrint('[Tony] cancelNotification: $id');
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

  @override
  Future<NotificationStatus> showNotification(
      int id, String title, String? body, tz.TZDateTime targetDateTime) async {
    tz.TZDateTime remindDate;
    if (kDebugMode) {
      remindDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    } else {
      var notifyTime = sharedPreferenceProvider.getMemoNotifyTime();
      var totalMinute = 24 * 60;
      var remindTimeInMinute = notifyTime.hour * 60 + notifyTime.minute;
      var subtractHour = (totalMinute - remindTimeInMinute) ~/ 60;
      var subtractMinute = (totalMinute - remindTimeInMinute) % 60;
      remindDate = targetDateTime
          .subtract(Duration(hours: subtractHour, minutes: subtractMinute));
    }

    if (tz.TZDateTime.now(tz.local).isAfter(remindDate)) {
      debugPrint('[Tony] showNotification due date in past, $remindDate');
      return Future.value(NotificationStatus.notificationDueDateInPast);
    }

    debugPrint(
        '[Tony] showNotification: $id, $title, $body, $targetDateTime $remindDate');

    if (Platform.isAndroid) {
      return showAndroidNotify(id, title, body, remindDate);
    } else if (Platform.isIOS) {
      return showIOSNotify(id, title, body, remindDate);
    } else {
      return Future.value(NotificationStatus.unknown);
    }
  }

  Future<NotificationStatus> showIOSNotify(
      int id, String title, String? body, tz.TZDateTime remindDate) {
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(threadIdentifier: 'joys_calendar');
    return _flutterLocalNotificationsPlugin
        .zonedSchedule(id, title, body, remindDate,
            const NotificationDetails(iOS: iOSPlatformChannelSpecifics),
            androidScheduleMode: AndroidScheduleMode.exact,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime)
        .then((value) => NotificationStatus.granted);
  }

  Future<NotificationStatus> showAndroidNotify(
      int id, String title, String? body, tz.TZDateTime remindDate) {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('我的記事頻道ID', '我的記事提醒',
            channelDescription: '',
            importance: Importance.max,
            visibility: NotificationVisibility.secret,
            priority: Priority.high);

    return _flutterLocalNotificationsPlugin
        .zonedSchedule(id, title, body, remindDate,
            const NotificationDetails(android: androidNotificationDetails),
            androidScheduleMode: AndroidScheduleMode.exact,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime)
        .then((value) => NotificationStatus.granted);
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

  @override
  Future<NotificationStatus> checkPermission() async {
    if (Platform.isAndroid) {
      var isInit = await _ensureInitialized();
      debugPrint('[Tony] isInit: $isInit');

      var areNotificationsEnabled = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .areNotificationsEnabled();

      debugPrint(
          '[Tony] Android areNotificationsEnabled: $areNotificationsEnabled');

      bool? permissionRequestResult;

      if (areNotificationsEnabled == false || areNotificationsEnabled == null) {
        permissionRequestResult = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .requestPermission();
      }

      debugPrint(
          '[Tony] Android permissionRequestResult: $permissionRequestResult');

      if (areNotificationsEnabled == false &&
          permissionRequestResult == false) {
        return Future.value(NotificationStatus.androidSettings);
      } else {
        return Future.value(NotificationStatus.granted);
      }
    } else if (Platform.isIOS) {
      var isInit = await _ensureInitialized();
      debugPrint('[Tony] iOS isInit: $isInit');

      var permissionRequestResult = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(alert: true, badge: true, sound: true);

      print('[Tony] iOS permissionRequestResult: $permissionRequestResult');

      if (permissionRequestResult == false) {
        return Future.value(NotificationStatus.iOSSettings);
      } else {
        return Future.value(NotificationStatus.granted);
      }
    } else {
      return Future.value(NotificationStatus.unknown);
    }
  }

  @override
  Future<bool> isPermissionGranted() async {
    var status =
        await NotificationPermissions.getNotificationPermissionStatus();
    debugPrint('[Tony] permission status = $status');
    return status == PermissionStatus.granted;
  }
}
