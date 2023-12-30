import 'package:flutter/foundation.dart';
import 'package:joys_calendar/common/extentions/event_model_extensions.dart';
import 'package:joys_calendar/common/extentions/local_notification_provider_extensions.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/calendar_model.dart';
import 'package:joys_calendar/repo/local/model/jieqi_model.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_dto/event_dto.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:lunar/lunar.dart';

class CalendarEventRepositoryImpl implements CalendarEventRepository {
  final CalendarApiClient _calendarApiClient;
  final SharedPreferenceProvider _sharedPreferenceProvider;
  final LocalDatasource localDatasource;
  final LocalNotificationProvider localNotificationProvider;
  final String apiKey;

  CalendarEventRepositoryImpl(
      this._calendarApiClient,
      this._sharedPreferenceProvider,
      this.localDatasource,
      this.apiKey,
      this.localNotificationProvider);

  @override
  Future<List<EventModel>> getEventsFromLocalDB(String country) async {
    List<EventModel> result = [];
    debugPrint('[Tony] getEventsFromLocalDB start ($country)');
    localDatasource.getCalendarModels(country).forEach((element) {
      EventModel eventModel = EventModel(
          date: element.dateTime,
          eventType: fromCreatorEmail(element.country)!,
          eventName: element.displayName);
      result.add(eventModel);
    });
    debugPrint(
        '[Tony] getEventsFromLocalDB end ($country), length=${result.length}');
    return result;
  }

  @override
  Future<List<EventModel>> getEvents(String country) async {
    List<EventModel> result = [];
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

      var continuousDayMap = result.fold({}, (map, element) {
        String key = element.getContinuousDayMapKey();
        map[key] = map[key] == null ? 0 : map[key] + 1;
        //debugPrint('[Tony] key=$key, value=${map[key]}');
        return map;
      });

      List<EventModel> firstTimeAddedCalendarModels =
          await localDatasource.saveCalendarModels(result
              .map((e) => CalendarModel()
                ..displayName = e.eventName
                ..dateTime = e.date
                ..country = e.eventType.toCountryCode()
                ..continuousDays = continuousDayMap[e.getContinuousDayMapKey()])
              .toList());

      if (_sharedPreferenceProvider.isCalendarNotifyEnable()) {
        var savedCalendarEvents =
            _sharedPreferenceProvider.getSavedCalendarEvents();
        if (firstTimeAddedCalendarModels.isNotEmpty &&
            savedCalendarEvents
                .contains(firstTimeAddedCalendarModels.first.eventType)) {
          var firstTimeAddedEventsContinuousDayMap =
              firstTimeAddedCalendarModels.fold({}, (map, element) {
            var key = element.getContinuousDayMapKey();
            map[key] = map[key] == null ? 0 : map[key]! + 1;
            return map;
          });

          for (var event in firstTimeAddedCalendarModels) {
            // debugPrint(
            //     '[Test] handle firsTimeNotify: ${event.eventName}, ${event.date}');
            localNotificationProvider.showCalendarNotify(
                event, firstTimeAddedEventsContinuousDayMap);
          }
        }
      }
      return result;
    } on Exception catch (e) {
      return result;
    }
  }

  @override
  Future<List<EventModel>> getLunarEvents(int year, int range) async {
    Map<String, int> arguments = {};
    arguments['year'] = year;
    arguments['range'] = range;
    List<EventModel> lunarEvents;
    // var start = DateTime.now().millisecondsSinceEpoch;
    lunarEvents = await compute(getLunarEventTask, arguments);
    // var cost = DateTime.now().millisecondsSinceEpoch - start;
    // debugPrint('[Tony] getLunarEvents($year, $range) cost $cost');
    return lunarEvents;
  }

  @override
  Future<List<EventModel>> getSolarEvents(int year, int range) async {
    // var start = DateTime.now().millisecondsSinceEpoch;
    List<EventModel> solarEvents;
    Map<String, int> arguments = {};
    arguments['year'] = year;
    arguments['range'] = range;
    solarEvents = await compute(getSolarEventTask, arguments);
    await localDatasource.saveJieQiModels(solarEvents
        .map((e) => JieQiModel()
          ..displayName = e.eventName
          ..dateTime = e.date)
        .toList());
    // var cost = DateTime.now().millisecondsSinceEpoch - start;
    // debugPrint('[Tony] getSolarEvents($year, $range) cost $cost');
    return Future.value(solarEvents);
  }

  @override
  Future<List<EventModel>> getSolarEventsFromLocalDB(int year) {
    var solarEvents = localDatasource
        .getJieQiModels()
        .where((element) => element.dateTime.year == year)
        .map((e) => EventModel(
            date: e.dateTime,
            eventType: EventType.solar,
            eventName: e.displayName))
        .toList();
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
    var start = DateTime.now().millisecondsSinceEpoch;
    int startYear = year - 1;
    int endYear = year + 1;
    List<EventModel> result = [];
    for (var year = startYear; year <= endYear; year++) {
      var dateTime = DateTime(year);
      for (var dayOfYear = 0; dayOfYear <= 364; dayOfYear++) {
        var thisDay = dateTime.add(Duration(days: dayOfYear));
        final memos = localDatasource.getMemos(thisDay);
        for (var element in memos) {
          // debugPrint('[Tony] getCustomEvent ${element.memo}');
          result.add(EventModel(
              date: thisDay,
              eventType: EventType.custom,
              eventName: element.memo,
              idForModify: element.key));
        }
      }
    }
    var cost = DateTime.now().millisecondsSinceEpoch - start;
    // around 1000 milliseconds
    // debugPrint('[Tony] getCustomEvent cost=$cost');
    return Future.value(result);
  }

  @override
  Future<List<EventModel>> search(String keyword) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    final countries = EventType.values.where((element) => element.index <= 5);
    List<EventModel> allEvents = [];

    List<EventModel> calendars = [];
    for (var country in countries) {
      calendars.addAll(localDatasource
          .getCalendarModels(country.toCountryCode())
          .where((element) => element.displayName.contains(keyword))
          .map((e) => EventModel(
              date: e.dateTime,
              eventType: fromCreatorEmail(e.country)!,
              eventName: e.displayName)));
    }

    List<EventModel> solarEvents = [];
    solarEvents.addAll(localDatasource
        .getJieQiModels()
        .where((element) => element.displayName.contains(keyword))
        .map((e) => EventModel(
            date: e.dateTime,
            eventType: EventType.solar,
            eventName: e.displayName)));

    List<EventModel> customEvents = [];
    customEvents.addAll(localDatasource
        .getAllMemos()
        .where((element) => element.memo.contains(keyword))
        .map((e) => EventModel(
            date: e.dateTime,
            eventType: EventType.custom,
            eventName: e.memo,
            idForModify: e.key)));

    allEvents.addAll(calendars);
    allEvents.addAll(solarEvents);
    allEvents.addAll(customEvents);
    allEvents.sort((a, b) => b.date.compareTo(a.date));

    final cost = DateTime.now().millisecondsSinceEpoch - start;
    debugPrint('[Tony] searching($keyword) cost $cost');
    return Future.value(allEvents);
  }

  @override
  Future<List<EventModel>> getFutureCustomEvents() {
    List<EventModel> result = [];
    var memos = localDatasource.getFutureMemos();
    for (var element in memos) {
      result.add(EventModel(
          date: element.dateTime,
          eventType: EventType.custom,
          eventName: element.memo,
          idForModify: element.key));
    }
    return Future.value(result);
  }

  @override
  Future<List<EventModel>> getFutureEventsFromLocalDB(String country) {
    List<EventModel> result = [];
    var calendars = localDatasource.getFutureCalendarModels(country);
    for (var element in calendars) {
      result.add(EventModel(
          date: element.dateTime,
          eventType: fromCreatorEmail(country)!,
          eventName: element.displayName,
          continuousDays: element.continuousDays));
    }
    return Future.value(result);
  }

  @override
  Future<List<EventModel>> getFutureSolarEvents() {
    List<EventModel> result = [];
    var jieQis = localDatasource.getFutureJieQiModels();
    for (var element in jieQis) {
      result.add(EventModel(
          date: element.dateTime,
          eventType: EventType.solar,
          eventName: element.displayName));
    }
    return Future.value(result);
  }
}

// TODO performance issue 20 years cost 519 milliseconds
// task on the other thread
List<EventModel> getLunarEventTask(dynamic map) {
  int startYear = map['year'] - map['range'];
  int endYear = map['year'] + map['range'];
  List<EventModel> result = [];
  for (var year = startYear; year <= endYear; year++) {
    var dateTime = DateTime(year);
    for (var dayOfYear = 0; dayOfYear <= 364; dayOfYear++) {
      var thisDay = dateTime.add(Duration(days: dayOfYear));
      var thisDayLunar = Lunar.fromDate(thisDay);
      result.add(EventModel(
          date: thisDay,
          eventType: EventType.lunar,
          eventName:
              "${thisDayLunar.getMonthInChinese()}月${thisDayLunar.getDayInChinese()}"));
    }
    // add next week lunar events for next year, because calendar will preview next week
    for (var dayOfYear = 0; dayOfYear <= 13; dayOfYear++) {
      var thisDay = dateTime.add(Duration(days: 365 + dayOfYear));
      var thisDayLunar = Lunar.fromDate(thisDay);
      result.add(EventModel(
          date: thisDay,
          eventType: EventType.lunar,
          eventName:
              "${thisDayLunar.getMonthInChinese()}月${thisDayLunar.getDayInChinese()}"));
    }

    // add previous week lunar events for next year, because calendar will preview previous week
    for (var dayOfYear = 1; dayOfYear <= 14; dayOfYear++) {
      var thisDay = dateTime.subtract(Duration(days: dayOfYear));
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
