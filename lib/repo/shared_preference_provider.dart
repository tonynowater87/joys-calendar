import 'package:flutter/material.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

abstract class SharedPreferenceProvider {
  Future<bool> setHasRunBefore(bool hasRunBefore);

  bool getHasRunBefore();

  Future<bool> setRecentRefreshCalendarNotificationTime(int recentRefreshCalendarNotificationTime);

  int? getRecentRefreshCalendarNotificationTime();

  Future<bool> saveCalendarEvents(List<EventType> calendarEvents);

  List<EventType> getSavedCalendarEvents();

  Future<bool> updatedGoogleCalendarYear(int year);

  int? getUpdatedGoogleCalendarYear();

  Future<bool> setMemoNotifyEnable(bool enable);

  bool isMemoNotifyEnable();

  Future<bool> setCalendarNotifyEnable(bool enable);

  bool isCalendarNotifyEnable();

  Future<bool> setSolarNotifyEnable(bool enable);

  bool isSolarNotifyEnable();

  Future<bool> setMemoNotifyTime(TimeOfDay timeOfDay);

  TimeOfDay getMemoNotifyTime();
}
