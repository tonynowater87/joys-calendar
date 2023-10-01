import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:joys_calendar/common/extentions/notify_id_extensions.dart';
import 'package:joys_calendar/common/utils/notification_helper.dart';
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
  NotificationHelper notificationHelper;

  SettingsNotifyCubit(
      {required this.localNotificationProvider,
      required this.sharedPreferenceProvider,
      required this.calendarEventRepository,
      required this.notificationHelper})
      : super(SettingsNotifyState(
            calendarNotify: sharedPreferenceProvider.isCalendarNotifyEnable(),
            memoNotify: sharedPreferenceProvider.isMemoNotifyEnable(),
            solarNotify: sharedPreferenceProvider.isSolarNotifyEnable(),
            showNotifyAlertPermissionDialog: false,
            notifyTime: sharedPreferenceProvider.getMemoNotifyTime(),
            isLoading: false));

  Future<void> setCalendarNotify(bool enable) async {
    if (enable) {
      var permission = await localNotificationProvider.checkPermission();
      if (permission != NotificationStatus.granted) {
        emit(state.copyWith(showNotifyAlertPermissionDialog: true));
        return;
      }
    }

    debugPrint('[Tony] setCalendarNotify: $enable');

    emit(state.copyWith(
        isLoading: true, showNotifyAlertPermissionDialog: false));
    var countries = sharedPreferenceProvider
        .getSavedCalendarEvents()
        .where((element) =>
            element != EventType.custom &&
            element != EventType.lunar &&
            element != EventType.solar)
        .toList();

    notificationHelper.setCalendarNotify(countries, enable);

    sharedPreferenceProvider.setCalendarNotifyEnable(enable);
    emit(state.copyWith(
        calendarNotify: enable,
        isLoading: false,
        showNotifyAlertPermissionDialog: false));
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

    emit(state.copyWith(
        isLoading: true, showNotifyAlertPermissionDialog: false));

    var hasSavedMemoEvent = sharedPreferenceProvider
        .getSavedCalendarEvents()
        .where((element) => element == EventType.custom)
        .toList()
        .isNotEmpty;

    if (hasSavedMemoEvent) {
      for (var event in await calendarEventRepository.getFutureCustomEvents()) {
        int id = event.getNotifyId();
        if (enable) {
          await localNotificationProvider.showNotification(id, event.eventName,
              null, tz.TZDateTime.from(event.date, tz.local));
        } else {
          await localNotificationProvider.cancelNotification(id);
        }
      }
    }

    sharedPreferenceProvider.setMemoNotifyEnable(enable);
    emit(state.copyWith(
        memoNotify: enable,
        showNotifyAlertPermissionDialog: false,
        isLoading: false));
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

    emit(state.copyWith(
        isLoading: true, showNotifyAlertPermissionDialog: false));
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
        solarNotify: enable,
        showNotifyAlertPermissionDialog: false,
        isLoading: false));
  }

  Future<void> setNotifyTime(TimeOfDay timeOfDay) async {
    var result = await sharedPreferenceProvider.setMemoNotifyTime(timeOfDay);

    if (result == false) {
      return;
    }

    emit(state.copyWith(
        isLoading: true, showNotifyAlertPermissionDialog: false));

    if (state.solarNotify) {
      var hasSavedSolarEvent = sharedPreferenceProvider
          .getSavedCalendarEvents()
          .where((element) => element == EventType.solar)
          .toList()
          .isNotEmpty;

      if (hasSavedSolarEvent) {
        for (var event
            in await calendarEventRepository.getFutureSolarEvents()) {
          int id = event.getNotifyId();
          await localNotificationProvider.showNotification(id, event.eventName,
              null, tz.TZDateTime.from(event.date, tz.local));
        }
      }
    }

    if (state.calendarNotify) {
      var countries = sharedPreferenceProvider.getSavedCalendarEvents().where(
          (element) =>
              element != EventType.custom &&
              element != EventType.lunar &&
              element != EventType.solar);
      for (var country in countries) {
        for (var event in await calendarEventRepository
            .getFutureEventsFromLocalDB(country.toCountryCode())) {
          int id = event.getNotifyId();
          await localNotificationProvider.showNotification(id, event.eventName,
              null, tz.TZDateTime.from(event.date, tz.local));
        }
      }
    }

    if (state.memoNotify) {
      var hasSavedMemoEvent = sharedPreferenceProvider
          .getSavedCalendarEvents()
          .where((element) => element == EventType.custom)
          .toList()
          .isNotEmpty;

      if (hasSavedMemoEvent) {
        for (var event
            in await calendarEventRepository.getFutureCustomEvents()) {
          int id = event.getNotifyId();
          await localNotificationProvider.showNotification(id, event.eventName,
              null, tz.TZDateTime.from(event.date, tz.local));
        }
      }
    }

    emit(state.copyWith(notifyTime: timeOfDay, isLoading: false));
  }
}
