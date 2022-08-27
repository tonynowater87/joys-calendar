import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_dto/event_dto.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:lunar/lunar.dart';

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
            eventType: EventType.taiwan,
            eventName: element.summary!);
        result.add(eventModel);
      });
      return result;
    } on Exception catch (e) {
      return result;
    }
  }

  @override
  List<EventModel> getLunarEvents(int year) {
    List<EventModel> result = [];
    var dateTime = DateTime(year);
    for (var dayOfYear = 1; dayOfYear <= 365; dayOfYear++) {
      var thisDay = dateTime.add(Duration(days: dayOfYear));
      var thisDayLunar = Lunar.fromDate(thisDay);
      result.add(EventModel(
          date: thisDay,
          eventType: EventType.lunar,
          eventName: "${thisDayLunar.getMonthInChinese()}月${thisDayLunar.getDayInChinese()}"));
    }
    return result;
  }
}
