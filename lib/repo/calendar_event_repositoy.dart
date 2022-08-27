import 'package:joys_calendar/repo/model/event_model.dart';

abstract class CalendarEventRepository {
  // params
  // country: en.uk
  Future<List<EventModel>> getEvents(String country);
}
