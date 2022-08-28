import 'package:joys_calendar/repo/model/event_model.dart';

abstract class CalendarEventRepository {
  Future<List<EventModel>> getEvents(String country);
  Future<List<EventModel>> getLunarEvents(int year);
}
