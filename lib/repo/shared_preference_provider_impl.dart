import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/event_model.dart';

class SharedPreferenceProviderImpl extends SharedPreferenceProvider {
  static const String _calendarKey = "CALENDAR_KEY";
  static const String _googleCalendarApiUpdatedYear = "GOOGLE_CALENDAR_API_UPDATED_YEAR";
  static const String _hasRunBefore = "HAS_RUN_BEFORE";
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
        ?.map((e) =>
    EventType.values[
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
}
