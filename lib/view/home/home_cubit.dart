import 'package:bloc/bloc.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:joys_calendar/common/extentions/calendar_event_extensions.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  static const platformOpenCC = MethodChannel('joyscalendar.opencc');

  late CalendarEventRepository calendarEventRepository;

  final int _currentYear = DateTime.now().year;

  HomeCubit(this.calendarEventRepository) : super(const HomeState.loading());

  Future<void> getEventFirstTime() async {
    debugPrint('[Tony] getEventFirstTime');

    List<List<EventModel>> allCountryEvents =
        await getAllSelectedCountryEvents(isFromLocal: true);

    Future<List<EventModel>> getLunarEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.lunar)) {
      getLunarEvents = calendarEventRepository.getLunarEvents(_currentYear, 1);
    } else {
      getLunarEvents = Future.value(List.empty());
    }

    Future<List<EventModel>> getSolarEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.solar)) {
      getSolarEvents =
          calendarEventRepository.getSolarEventsFromLocalDB(_currentYear);
    } else {
      getSolarEvents = Future.value(List.empty());
    }

    Future<List<EventModel>> getCustomEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.custom)) {
      getCustomEvents = calendarEventRepository.getCustomEvents(_currentYear);
    } else {
      getCustomEvents = Future.value(List.empty());
    }

    Future.wait([getLunarEvents, getSolarEvents, getCustomEvents])
        .then((localEvents) {
      final List<CalendarEvent> combinedCalendarEvents = [];
      localEvents.addAll(allCountryEvents);
      for (var events in localEvents) {
        combinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            order: e.eventType == EventType.lunar ? -1 : e.eventType.index,
            eventName: e.eventName,
            eventDate: e.date,
            eventID: e.eventType.name,
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }
      debugPrint('[Tony] update all event ${DateTime.now()}');
      emit(HomeState.success(combinedCalendarEvents));
      refreshGoogleCalendarHolidays();
    });
  }

  Future<void> refreshGoogleCalendarHolidays() async {
    final List<CalendarEvent> originCombinedCalendarEvents =
        state.events.toList();

    List<List<EventModel>> allCountryEvents =
        await getAllSelectedCountryEvents(isFromLocal: false);

    for (var events in allCountryEvents) {
      if (events.isNotEmpty) {
        // remove old event-type data from database
        originCombinedCalendarEvents.removeWhere(
            (element) => element.eventID == events.first.eventType.name);

        // add new event-type data from api
        originCombinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            order: e.eventType.index,
            eventName: e.eventName,
            eventDate: e.date,
            eventID: e.eventType.name,
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }
    }
    emit(HomeState.success(originCombinedCalendarEvents));
  }

  Future<void> refreshGoogleCalendarHolidaysFromSettings() async {
    final List<CalendarEvent> originCombinedCalendarEvents =
        state.events.toList();

    // remove all country
    originCombinedCalendarEvents
        .removeWhere((element) => element.isGoogleCalendarEvent());

    List<List<EventModel>> allCountryEvents =
        await getAllSelectedCountryEvents(isFromLocal: false);

    // add country events back by settings
    for (var events in allCountryEvents) {
      if (events.isNotEmpty) {
        originCombinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            order: e.eventType.index,
            eventName: e.eventName,
            eventDate: e.date,
            eventID: e.eventType.name,
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }
    }
    emit(HomeState.success(originCombinedCalendarEvents));
  }

  Future<List<List<EventModel>>> getAllSelectedCountryEvents(
      {required bool isFromLocal}) async {
    var eventTypes = EventType.values;
    List<Future<List<EventModel>>> futures = [];

    for (var eventType in eventTypes) {
      try {
        Future<List<EventModel>> future;
        if (calendarEventRepository.getDisplayEventType().contains(eventType)) {
          if (isFromLocal) {
            future = calendarEventRepository
                .getEventsFromLocalDB(eventType.toCountryCode());
          } else {
            future =
                calendarEventRepository.getEvents(eventType.toCountryCode());
          }
          futures.add(future);
        } else {
          futures.add(Future.value(List.empty()));
        }
      } on Exception catch (e) {
        // fixme toCountryCode Exception
        debugPrint('[Tony] exception: $e');
        continue;
      }
    }
    return Future.wait(futures);
  }

  /*Future<void> getSolarEvents(
      List<CalendarEvent> combinedCalendarEvents) async {
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.solar)) {
      var solarEvents =
          await calendarEventRepository.getSolarEvents(_currentYear, 5);
      combinedCalendarEvents.addAll(solarEvents.map((e) => CalendarEvent(
          order: e.eventType.index,
          eventName: e.eventName,
          eventDate: e.date,
          eventBackgroundColor: e.eventType.toEventColor(),
          eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!)));
    }
  }

  Future<void> getLunarEvents(
      List<CalendarEvent> combinedCalendarEvents, int range) async {
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.lunar)) {
      var lunarEvents =
          await calendarEventRepository.getLunarEvents(_currentYear, range);
      combinedCalendarEvents.addAll(lunarEvents.map((e) => CalendarEvent(
          eventName: e.eventName,
          eventDate: e.date,
          eventBackgroundColor: e.eventType.toEventColor(),
          eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!,
          order: -1)));
    }
  }

  Future<void> getCustomEvents(
      List<CalendarEvent> combinedCalendarEvents) async {
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.custom)) {
      var customEvents =
          await calendarEventRepository.getCustomEvents(_currentYear);
      combinedCalendarEvents.addAll(customEvents.map((e) => CalendarEvent(
          order: e.eventType.index,
          eventName: e.eventName,
          eventDate: e.date,
          eventBackgroundColor: e.eventType.toEventColor(),
          eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!)));
    }
  }*/

  void refreshFromAddOrUpdateCustomEvent() async {
    var newEventsList = state.events.toList();
    var updatedCustomEvents =
        await calendarEventRepository.getCustomEvents(_currentYear);
    newEventsList
        .removeWhere((element) => element.eventID == EventType.custom.name);
    newEventsList.addAll(updatedCustomEvents.map((e) => CalendarEvent(
        order: e.eventType.index,
        eventName: e.eventName,
        eventDate: e.date,
        eventID: e.eventType.name,
        eventBackgroundColor: e.eventType.toEventColor(),
        eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!)));
    emit(HomeState.success(newEventsList));
  }
}
