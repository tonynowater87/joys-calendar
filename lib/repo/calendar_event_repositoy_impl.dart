import 'package:flutter/foundation.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_dto/event_dto.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:lunar/lunar.dart';

class CalendarEventRepositoryImpl implements CalendarEventRepository {

  late CalendarApiClient calendarApiClient;
  List<EventType> eventTypes = [EventType.taiwan, EventType.japan, EventType.lunar, EventType.solar];

  CalendarEventRepositoryImpl(this.calendarApiClient);

  @override
  Future<List<EventModel>> getEvents(String country) async {
    String format = "$country%23holiday%40group.v.calendar.google.com/events";
    List<EventModel> result = [];
    try {
      EventDto eventDto = await calendarApiClient.getEvents(format);
      eventDto.items?.takeWhile((element) {
        return fromCreatorEmail(element.creator?.email) != null;
      }).forEach((element) {
        EventModel eventModel = EventModel(
            date: DateTime.parse(element.start!.date!),
            eventType: fromCreatorEmail(element.creator!.email!)!,
            eventName: element.summary!);
        result.add(eventModel);
      });
      return result;
    } on Exception catch (e) {
      return result;
    }
  }

  @override
  Future<List<EventModel>> getLunarEvents(int year) {
    return compute(getLunarEventTask, year);
  }

  @override
  List<EventType> getDisplayEventType() {
    return eventTypes.toList();
  }

  @override
  void setDisplayEventType(List<EventType> eventTypes) {
    this.eventTypes = eventTypes.toList();
  }
}

// task on the other thread
List<EventModel> getLunarEventTask(int year) {
  int startYear = year - 1;
  int endYear = year + 1;
  List<EventModel> result = [];
  for (var year = startYear; year <= endYear; year++) {
    var dateTime = DateTime(year);
    for (var dayOfYear = 1; dayOfYear <= 365; dayOfYear++) {
      var thisDay = dateTime.add(Duration(days: dayOfYear));
      var thisDayLunar = Lunar.fromDate(thisDay);
      var jieQi = thisDayLunar.getJieQi();
      if (jieQi.isNotEmpty) {
        result.add(EventModel(
            date: thisDay, eventType: EventType.solar, eventName: jieQi));
      }
      result.add(EventModel(
          date: thisDay,
          eventType: EventType.lunar,
          eventName:
              "${thisDayLunar.getMonthInChinese()}月${thisDayLunar.getDayInChinese()}"));
    }
  }
  return result;
}
