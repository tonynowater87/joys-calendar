import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
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
            solarNotify: sharedPreferenceProvider.isSolarNotifyEnable()));

  Future<void> setCalendarNotify(bool enable) async {
    var permission = await localNotificationProvider.checkPermission();
    if (permission != NotificationStatus.granted) {
      return;
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
        int id = (event.date.millisecondsSinceEpoch & 0xFFFFFFFF >>> 2) +
            event.eventType.index;

        if (enable) {
          localNotificationProvider.showNotification(id, event.eventName, null,
              tz.TZDateTime.from(event.date, tz.local));
        } else {
          localNotificationProvider.cancelNotification(id);
        }
      }
    }

    sharedPreferenceProvider.setCalendarNotifyEnable(enable);
    emit(SettingsNotifyState(
        calendarNotify: enable,
        memoNotify: state.memoNotify,
        solarNotify: state.solarNotify));
  }

  Future<void> setMemoNotify(bool enable) async {
    var permission = await localNotificationProvider.checkPermission();
    if (permission != NotificationStatus.granted) {
      return;
    }
    debugPrint('[Tony] setMemoNotify: $enable');

    for (var event in await calendarEventRepository.getFutureCustomEvents()) {
      int id = (event.date.millisecondsSinceEpoch & 0xFFFFFFFF >>> 2) +
          (int.tryParse(event.idForModify.toString()) ?? 0) +
          EventType.values.length;
      if (enable) {
        localNotificationProvider.showNotification(id, event.eventName, null,
            tz.TZDateTime.from(event.date, tz.local));
      } else {
        localNotificationProvider.cancelNotification(id);
      }
    }

    sharedPreferenceProvider.setMemoNotifyEnable(enable);
    emit(SettingsNotifyState(
        calendarNotify: state.calendarNotify,
        memoNotify: enable,
        solarNotify: state.solarNotify));
  }

  Future<void> setSolarNotify(bool enable) async {
    var permission = await localNotificationProvider.checkPermission();
    if (permission != NotificationStatus.granted) {
      return;
    }
    debugPrint('[Tony] setSolarNotify: $enable');

    for (var event in await calendarEventRepository.getFutureSolarEvents()) {
      int id = (event.date.millisecondsSinceEpoch & 0xFFFFFFFF >>> 2) +
          event.eventType.index;
      if (enable) {
        localNotificationProvider.showNotification(id, event.eventName, null,
            tz.TZDateTime.from(event.date, tz.local));
      } else {
        localNotificationProvider.cancelNotification(id);
      }
    }

    sharedPreferenceProvider.setSolarNotifyEnable(enable);
    emit(SettingsNotifyState(
        calendarNotify: state.calendarNotify,
        memoNotify: state.memoNotify,
        solarNotify: enable));
  }

  void _checkPermission() {}
}
