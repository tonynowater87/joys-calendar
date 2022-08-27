import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_dto/event_dto.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

class CalendarEventRepositoryImpl implements CalendarEventRepository {
  late CalendarApiClient calendarApiClient;

  CalendarEventRepositoryImpl(this.calendarApiClient);

  @override
  Future<List<EventModel>> getEvents(String country) async {
    String format = "$country%23holiday%40group.v.calendar.google.com/events";
    List<EventModel> result = [];
    try {
      EventDto eventDto = await calendarApiClient.getEvents(format);
      eventDto.items?.forEach((element) {
        EventModel eventModel = EventModel(
            date: DateTime.parse(element.start!.date!),
            eventType: EventType.Taiwan,
            eventName: element.summary!);
        result.add(eventModel);
      });
      return result;
    } on Exception catch (e) {
      return result;
    }
  }
}
