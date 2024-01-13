import 'package:bloc/bloc.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:joys_calendar/common/extentions/calendar_event_extensions.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/common/utils/string_utils.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {

  final CalendarEventRepository _calendarEventRepository;

  int _currentYear = DateTime.now().year;

  HomeCubit(this._calendarEventRepository) : super(const HomeState.loading());

  Future<void> getEventWhenAppLaunch() async {
    var start = DateTime.now().millisecondsSinceEpoch;

    List<List<EventModel>> allCountryEvents =
        await _getAllSelectedCountryEvents(isFromLocal: true);

    Future<List<EventModel>> lunarEvents = _getLunarEvents(_currentYear);

    Future<List<EventModel>> solarEvents = _getSolarEvents(_currentYear);

    Future<List<EventModel>> getCustomEvents = _getCustomEvents();

    Future.wait([lunarEvents, solarEvents, getCustomEvents])
        .then((localEvents) {
      final List<CalendarEvent> combinedCalendarEvents = [];
      localEvents.addAll(allCountryEvents);
      for (var events in localEvents) {
        combinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            order: e.eventType == EventType.lunar ? -1 : e.eventType.index,
            eventName: e.eventName,
            eventDate: e.date,
            eventID: StringUtils.combineEventTypeAndIdForModify(e.eventType.name, e.idForModify),
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }
      var cost = DateTime.now().millisecondsSinceEpoch - start;
      debugPrint('[Tony] update all event, cost=$cost');
      emit(HomeState.success(combinedCalendarEvents));
      refreshGoogleCalendarHolidays();
    });
  }

  Future<void> refreshGoogleCalendarHolidays() async {
    final List<CalendarEvent> originCombinedCalendarEvents =
        state.events.toList();

    List<List<EventModel>> allCountryEvents =
        await _getAllSelectedCountryEvents(isFromLocal: false);
    debugPrint('[Tony] refreshGoogleCalendarHolidays done');

    for (var events in allCountryEvents) {
      if (events.isNotEmpty &&
          _calendarEventRepository
              .getDisplayEventType()
              .contains(events.first.eventType)) {
        // remove old event-type data from database
        originCombinedCalendarEvents.removeWhere(
            (element) => element.extractEventTypeName() == events.first.eventType.name);

        // add new event-type data from api
        originCombinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            order: e.eventType.index,
            eventName: e.eventName,
            eventDate: e.date,
            eventID: StringUtils.combineEventTypeAndIdForModify(e.eventType.name, e.idForModify),
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }
    }
    emit(HomeState.success(originCombinedCalendarEvents));
  }

  Future<void> refreshAllEventsFromSettings() async {
    final List<CalendarEvent> originCombinedCalendarEvents = [];

    List<List<EventModel>> allEvents =
        await _getAllSelectedCountryEvents(isFromLocal: true);

    allEvents.addAll(await Future.wait([
      _getSolarEvents(_currentYear),
      _getLunarEvents(_currentYear),
      _getCustomEvents()
    ]));

    // add all events back by settings
    for (var events in allEvents) {
      if (events.isNotEmpty) {
        originCombinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            order: e.eventType == EventType.lunar ? -1 : e.eventType.index,
            eventName: e.eventName,
            eventDate: e.date,
            eventID: StringUtils.combineEventTypeAndIdForModify(e.eventType.name, e.idForModify),
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }
    }

    emit(HomeState.success(originCombinedCalendarEvents));
  }

  Future<List<List<EventModel>>> _getAllSelectedCountryEvents(
      {required bool isFromLocal}) async {
    var eventTypes = EventType.values;
    List<Future<List<EventModel>>> futures = [];

    for (var eventType in eventTypes) {
      try {
        Future<List<EventModel>> future;
        if (isFromLocal) {
          if (_calendarEventRepository
              .getDisplayEventType()
              .contains(eventType)) {
            future = _calendarEventRepository
                .getEventsFromLocalDB(eventType.toCountryCode());
          } else {
            future = Future.value(List.empty());
          }
        } else {
          future = _calendarEventRepository.getEvents(eventType.toCountryCode());
        }
        futures.add(future);
      } on Exception catch (e) {
        // fixme toCountryCode Exception
        debugPrint('[Tony] exception: $e');
        continue;
      }
    }
    return Future.wait(futures);
  }

  Future<List<EventModel>> _getCustomEvents() {
    if (_calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.custom)) {
      return _calendarEventRepository.getCustomEvents(_currentYear);
    } else {
      return Future.value(List.empty());
    }
  }

  Future<List<EventModel>> _getSolarEvents(int year) async {
    if (_calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.solar)) {
      var events =
          await _calendarEventRepository.getSolarEventsFromLocalDB(year);
      if (events.isEmpty) {
        return _calendarEventRepository.getSolarEvents(year, 0);
      } else {
        return Future.value(events);
      }
    } else {
      return Future(List.empty);
    }
  }

  Future<List<EventModel>> _getLunarEvents(int year) async {
    if (_calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.lunar)) {
      return _calendarEventRepository.getLunarEvents(year, 0);
    } else {
      return Future(List.empty);
    }
  }

  Future<void> refreshFromAddOrUpdateCustomEvent() async {
    var updatedCustomEvents = await _getCustomEvents();
    var newEventsList = state.events.toList();
    newEventsList.removeWhere(
        (element) => element.extractEventTypeName() == EventType.custom.name);
    newEventsList.addAll(updatedCustomEvents.map((e) => CalendarEvent(
        order: e.eventType.index,
        eventName: e.eventName,
        eventDate: e.date,
        eventID: StringUtils.combineEventTypeAndIdForModify(
            e.eventType.name, e.idForModify),
        eventBackgroundColor: e.eventType.toEventColor(),
        eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!)));
    emit(HomeState.success(newEventsList));
  }

  Future<void> refreshWhenYearChanged(int year) async {
    if (_currentYear == year) {
      return;
    }
    _currentYear = year;
    var newEventsList = state.events.toList();
    Future.wait(
            [_getLunarEvents(year), _getSolarEvents(year), _getCustomEvents()])
        .then((allRefreshedEvents) {
      for (var refreshEvents in allRefreshedEvents) {
        for (var refreshEvent in refreshEvents) {
          if (newEventsList.indexWhere((element) =>
                  element.extractEventTypeName() == refreshEvent.eventType.name &&
                  element.eventDate == refreshEvent.date) !=
              -1) {
            continue;
          }
          newEventsList.add(CalendarEvent(
              order: refreshEvent.eventType == EventType.lunar
                  ? -1
                  : refreshEvent.eventType.index,
              eventName: refreshEvent.eventName,
              eventDate: refreshEvent.date,
              eventID: StringUtils.combineEventTypeAndIdForModify(refreshEvent.eventType.name, refreshEvent.idForModify),
              eventBackgroundColor: refreshEvent.eventType.toEventColor(),
              eventTextStyle:
                  JoysCalendarThemeData.calendarTextTheme.overline!));
        }
      }
      emit(HomeState.success(newEventsList));
    });
  }

  void copyEventToClipboard(CalendarEvent event) {
    Clipboard.setData(ClipboardData(text: event.eventName));
  }
}
