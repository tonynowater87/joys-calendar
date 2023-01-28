import 'package:flutter/foundation.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/calendar_model.dart';
import 'package:joys_calendar/repo/local/model/jieqi_model.dart';
import 'package:joys_calendar/repo/model/event_dto/event_dto.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:lunar/lunar.dart';

class CalendarEventRepositoryImpl implements CalendarEventRepository {
  final CalendarApiClient _calendarApiClient;
  final SharedPreferenceProvider _sharedPreferenceProvider;
  final LocalDatasource localDatasource;
  final String apiKey;

  CalendarEventRepositoryImpl(this._calendarApiClient,
      this._sharedPreferenceProvider, this.localDatasource, this.apiKey);

  @override
  Future<List<EventModel>> getEvents(String country) async {
    final currentYear = DateTime.now().year;
    var updatedGoogleCalendarYear =
        _sharedPreferenceProvider.getUpdatedGoogleCalendarYear();
    var hasSavedCountry = localDatasource.getCalendarModels(country).isNotEmpty;
    List<EventModel> result = [];
    if (updatedGoogleCalendarYear != null &&
        updatedGoogleCalendarYear == currentYear &&
        hasSavedCountry) {
      localDatasource.getCalendarModels(country).forEach((element) {
        EventModel eventModel = EventModel(
            date: element.dateTime,
            eventType: fromCreatorEmail(element.country)!,
            eventName: element.displayName);
        result.add(eventModel);
      });
      return result;
    } else {
      String format = "$country%23holiday%40group.v.calendar.google.com/events";
      try {
        EventDto eventDto = await _calendarApiClient.getEvents(format, apiKey);
        eventDto.items?.takeWhile((element) {
          return fromCreatorEmail(element.creator?.email) != null;
        }).forEach((element) {
          EventModel eventModel = EventModel(
              date: DateTime.parse(element.start!.date!),
              eventType: fromCreatorEmail(element.creator!.email!)!,
              eventName: element.summary!);
          result.add(eventModel);
        });

        await localDatasource.saveCalendarModels(result
            .map((e) => CalendarModel()
              ..displayName = e.eventName
              ..dateTime = e.date
              ..country = e.eventType.toCountryCode())
            .toList());
        await _sharedPreferenceProvider.updatedGoogleCalendarYear(currentYear);
        return result;
      } on Exception catch (e) {
        return result;
      }
    }
  }

  @override
  Future<List<EventModel>> getLunarEvents(int year) {
    return compute(getLunarEventTask, year);
  }

  @override
  Future<List<EventModel>> getSolarEvents(int year) async {
    final hasJieQi = localDatasource
        .getJieQiModels()
        .where((element) => element.dateTime.year == year)
        .isNotEmpty;
    List<EventModel> solarEvents;
    Map<String, int> arguments = {};
    if (hasJieQi) {
      var solarEvents = localDatasource
          .getJieQiModels()
          .map((e) => EventModel(
              date: e.dateTime,
              eventType: EventType.solar,
              eventName: e.displayName))
          .toList();
      return Future.value(solarEvents);
    } else {
      arguments['year'] = year;
      arguments['range'] = 3;
      solarEvents = await compute(getSolarEventTask, arguments);
    }
    await localDatasource.saveJieQiModels(solarEvents
        .map((e) => JieQiModel()
          ..displayName = e.eventName
          ..dateTime = e.date)
        .toList());
    return Future.value(solarEvents);
  }

  @override
  List<EventType> getDisplayEventType() {
    return _sharedPreferenceProvider.getSavedCalendarEvents();
  }

  @override
  Future<void> setDisplayEventType(List<EventType> eventTypes) async {
    await _sharedPreferenceProvider.saveCalendarEvents(eventTypes);
  }

  @override
  Future<List<EventModel>> getCustomEvents(int year) async {
    int startYear = year - 30;
    int endYear = year + 30;
    List<EventModel> result = [];
    for (var year = startYear; year <= endYear; year++) {
      var dateTime = DateTime(year);
      for (var dayOfYear = 1; dayOfYear <= 365; dayOfYear++) {
        var thisDay = dateTime.add(Duration(days: dayOfYear));
        final memos = localDatasource.getMemos(thisDay);
        for (var element in memos) {
          result.add(EventModel(
              date: thisDay,
              eventType: EventType.custom,
              eventName: element.memo));
        }
      }
    }
    return Future.value(result);
  }
}

// TODO performance issue 20 years cost 519 milliseconds
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
      result.add(EventModel(
          date: thisDay,
          eventType: EventType.lunar,
          eventName:
              "${thisDayLunar.getMonthInChinese()}月${thisDayLunar.getDayInChinese()}"));
    }
  }

  return result;
}

// task on the other thread
List<EventModel> getSolarEventTask(dynamic map) {
  int startYear = map['year'] - map['range'];
  int endYear = map['year'] + map['range'];
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
    }
  }
  return result;
}
