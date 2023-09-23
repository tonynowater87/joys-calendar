import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';

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

  void setCalendarNotify(bool enable) {
    debugPrint('[Tony] setCalendarNotify: $enable');
    sharedPreferenceProvider.setCalendarNotifyEnable(enable);
    emit(SettingsNotifyState(
        calendarNotify: enable,
        memoNotify: state.memoNotify,
        solarNotify: state.solarNotify));
  }

  void setMemoNotify(bool enable) {
    debugPrint('[Tony] setMemoNotify: $enable');
    sharedPreferenceProvider.setMemoNotifyEnable(enable);
    emit(SettingsNotifyState(
        calendarNotify: state.calendarNotify,
        memoNotify: enable,
        solarNotify: state.solarNotify));
  }

  void setSolarNotify(bool enable) {
    debugPrint('[Tony] setSolarNotify: $enable');
    sharedPreferenceProvider.setSolarNotifyEnable(enable);
    emit(SettingsNotifyState(
        calendarNotify: state.calendarNotify,
        memoNotify: state.memoNotify,
        solarNotify: enable));
  }

  void _checkPermission() {}
}
