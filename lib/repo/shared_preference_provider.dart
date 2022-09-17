import 'package:joys_calendar/repo/model/event_model.dart';

abstract class SharedPreferenceProvider {
  Future<bool> saveCalendarEvents(List<EventType> calendarEvents);

  List<EventType> getSavedCalendarEvents();
}
