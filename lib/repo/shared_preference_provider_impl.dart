import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/event_model.dart';

class SharedPreferenceProviderImpl extends SharedPreferenceProvider {
  static const String _calendarKey = "CALENDAR_KEY";
  static const List<EventType> _defaultCalendarEvent = [
    EventType.taiwan,
    EventType.japan,
    EventType.lunar,
    EventType.solar
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
}
