import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:joys_calendar/common/extentions/notify_id_extensions.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:timezone/timezone.dart' as tz;

part 'settings_notify_state.dart';

class SettingsNotifyCubit extends Cubit<SettingsNotifyState> {
  LocalNotificationProvider localNotificationProvider;
  SharedPreferenceProvider sharedPreferenceProvider;
  CalendarEventRepository calendarEventRepository;

  SettingsNotifyCubit(
      {required this.localNotificationProvider,
      required this.sharedPreferenceProvider,
      required this.calendarEventRepository})
      : super(SettingsNotifyState(
            calendarNotify: sharedPreferenceProvider.isCalendarNotifyEnable(),
            memoNotify: sharedPreferenceProvider.isMemoNotifyEnable(),
            solarNotify: sharedPreferenceProvider.isSolarNotifyEnable(),
            showNotifyAlertPermissionDialog: false));

  Future<void> setCalendarNotify(bool enable) async {
    if (enable) {
      var permission = await localNotificationProvider.checkPermission();
      if (permission != NotificationStatus.granted) {
        emit(state.copyWith(showNotifyAlertPermissionDialog: true));
        return;
      }
    }

    debugPrint('[Tony] setCalendarNotify: $enable');

    var countries = sharedPreferenceProvider.getSavedCalendarEvents().where(
        (element) =>
            element != EventType.custom &&
            element != EventType.lunar &&
            element != EventType.solar);
    for (var country in countries) {
      for (var event in await calendarEventRepository
          .getFutureEventsFromLocalDB(country.toCountryCode())) {
        int id = event.getNotifyId();
        if (enable) {
          localNotificationProvider.showNotification(id, event.eventName, null,
              tz.TZDateTime.from(event.date, tz.local));
        } else {
          localNotificationProvider.cancelNotification(id);
        }
      }
    }

    sharedPreferenceProvider.setCalendarNotifyEnable(enable);
    emit(state.copyWith(
        calendarNotify: enable, showNotifyAlertPermissionDialog: false));
  }

  Future<void> setMemoNotify(bool enable) async {
    if (enable) {
      var permission = await localNotificationProvider.checkPermission();
      if (permission != NotificationStatus.granted) {
        emit(state.copyWith(showNotifyAlertPermissionDialog: true));
        return;
      }
    }

    debugPrint('[Tony] setMemoNotify: $enable');

    for (var event in await calendarEventRepository.getFutureCustomEvents()) {
      int id = event.getNotifyId();
      if (enable) {
        localNotificationProvider.showNotification(id, event.eventName, null,
            tz.TZDateTime.from(event.date, tz.local));
      } else {
        localNotificationProvider.cancelNotification(id);
      }
    }

    sharedPreferenceProvider.setMemoNotifyEnable(enable);
    emit(state.copyWith(
        memoNotify: enable, showNotifyAlertPermissionDialog: false));
  }

  Future<void> setSolarNotify(bool enable) async {
    if (enable) {
      var permission = await localNotificationProvider.checkPermission();
      if (permission != NotificationStatus.granted) {
        emit(state.copyWith(showNotifyAlertPermissionDialog: true));
        return;
      }
    }

    debugPrint('[Tony] setSolarNotify: $enable');

    var hasSavedSolarEvent = sharedPreferenceProvider
        .getSavedCalendarEvents()
        .where((element) => element == EventType.solar)
        .toList()
        .isNotEmpty;

    if (hasSavedSolarEvent) {
      for (var event in await calendarEventRepository.getFutureSolarEvents()) {
        int id = event.getNotifyId();
        if (enable) {
          localNotificationProvider.showNotification(id, event.eventName, null,
              tz.TZDateTime.from(event.date, tz.local));
        } else {
          localNotificationProvider.cancelNotification(id);
        }
      }
    }

    sharedPreferenceProvider.setSolarNotifyEnable(enable);
    emit(state.copyWith(
        solarNotify: enable, showNotifyAlertPermissionDialog: false));
  }
}
