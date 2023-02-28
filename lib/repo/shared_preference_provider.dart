import 'package:joys_calendar/repo/model/event_model.dart';

abstract class SharedPreferenceProvider {
  Future<bool> setHasRunBefore(bool hasRunBefore);

  bool getHasRunBefore();

  Future<bool> saveCalendarEvents(List<EventType> calendarEvents);

  List<EventType> getSavedCalendarEvents();

  Future<bool> updatedGoogleCalendarYear(int year);

  int? getUpdatedGoogleCalendarYear();
}
