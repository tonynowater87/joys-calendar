import 'package:joys_calendar/repo/model/event_model.dart';

abstract class CalendarEventRepository {
  List<EventModel> getFutureEventsFromLocalDB(String country);

  Future<List<EventModel>> getEventsFromLocalDB(String country);

  Future<List<EventModel>> getEvents(String country);

  Future<List<EventModel>> getLunarEvents(int year, int range);

  Future<List<EventModel>> getSolarEventsFromLocalDB(int year);

  Future<List<EventModel>> getSolarEvents(int year, int range);

  Future<List<EventModel>> getFutureSolarEvents();

  Future<List<EventModel>> getCustomEvents(int year);

  Future<List<EventModel>> getFutureCustomEvents();

  Future<void> setDisplayEventType(List<EventType> eventTypes);

  List<EventType> getDisplayEventType();

  Future<List<EventModel>> search(String keyword);
}
