import 'package:flutter/material.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/event_model.dart';

class SharedPreferenceProviderImpl extends SharedPreferenceProvider {
  static const String _calendarKey = "CALENDAR_KEY";
  static const String _googleCalendarApiUpdatedYear =
      "GOOGLE_CALENDAR_API_UPDATED_YEAR";
  static const String _hasRunBefore = "HAS_RUN_BEFORE";
  static const String _isMemoNotifyEnable = "IS_MEMO_NOTIFY_ENABLE";
  static const String _isCalendarNotifyEnable = "IS_CALENDAR_NOTIFY_ENABLE";
  static const String _isSolarNotifyEnable = "IS_SOLAR_NOTIFY_ENABLE";
  static const String _notifyTime = "NOTIFY_TIME";
  static const String _recentRefreshCalendarNotificationTime =
      "RECENT_REFRESH_CALENDAR_NOTIFICATION_TIME";

  static const List<EventType> _defaultCalendarEvent = [
    EventType.taiwan,
    EventType.lunar,
    EventType.solar,
    EventType.custom,
  ];

  final SharedPreferences _sharedPreferences;

  SharedPreferenceProviderImpl(this._sharedPreferences);

  @override
  List<EventType> getSavedCalendarEvents() {
    return _sharedPreferences
            .getStringList(_calendarKey)
            ?.map((e) => EventType.values[
                EventType.values.indexWhere((element) => element.name == e)])
            .toList() ??
        _defaultCalendarEvent;
  }

  @override
  Future<bool> saveCalendarEvents(List<EventType> calendarEvents) {
    return _sharedPreferences.setStringList(
        _calendarKey, calendarEvents.map((e) => e.name).toList());
  }

  @override
  int? getUpdatedGoogleCalendarYear() {
    return _sharedPreferences.getInt(_googleCalendarApiUpdatedYear);
  }

  @override
  Future<bool> updatedGoogleCalendarYear(int year) {
    return _sharedPreferences.setInt(_googleCalendarApiUpdatedYear, year);
  }

  @override
  bool getHasRunBefore() {
    return _sharedPreferences.getBool(_hasRunBefore) ?? false;
  }

  @override
  Future<bool> setHasRunBefore(bool hasRunBefore) {
    return _sharedPreferences.setBool(_hasRunBefore, hasRunBefore);
  }

  @override
  bool isMemoNotifyEnable() {
    return _sharedPreferences.getBool(_isMemoNotifyEnable) ?? false;
  }

  @override
  Future<bool> setMemoNotifyEnable(bool enable) {
    return _sharedPreferences.setBool(_isMemoNotifyEnable, enable);
  }

  @override
  bool isCalendarNotifyEnable() {
    return _sharedPreferences.getBool(_isCalendarNotifyEnable) ?? false;
  }

  @override
  Future<bool> setCalendarNotifyEnable(bool enable) {
    return _sharedPreferences.setBool(_isCalendarNotifyEnable, enable);
  }

  @override
  bool isSolarNotifyEnable() {
    return _sharedPreferences.getBool(_isSolarNotifyEnable) ?? false;
  }

  @override
  Future<bool> setSolarNotifyEnable(bool enable) {
    return _sharedPreferences.setBool(_isSolarNotifyEnable, enable);
  }

  @override
  Future<bool> setMemoNotifyTime(TimeOfDay timeOfDay) {
    return _sharedPreferences.setInt(
        _notifyTime, timeOfDay.hour * 60 + timeOfDay.minute);
  }

  @override
  TimeOfDay getMemoNotifyTime() {
    final int? time = _sharedPreferences.getInt(_notifyTime);
    if (time == null) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    return TimeOfDay(hour: time ~/ 60, minute: time % 60);
  }

  @override
  int? getRecentRefreshCalendarNotificationTime() {
    return _sharedPreferences.getInt(_recentRefreshCalendarNotificationTime);
  }

  @override
  Future<bool> setRecentRefreshCalendarNotificationTime(
      int recentRefreshCalendarNotificationTime) {
    return _sharedPreferences.setInt(_recentRefreshCalendarNotificationTime,
        recentRefreshCalendarNotificationTime);
  }
}
