import 'package:bloc/bloc.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    final List<CalendarEvent> combinedCalendarEvents = [];
    Future<List<EventModel>> getTaiwanEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.taiwan)) {
      getTaiwanEvents = calendarEventRepository
          .getEventsFromLocalDB(EventType.taiwan.toCountryCode());
    } else {
      getTaiwanEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getChinaEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.china)) {
      getChinaEvents = calendarEventRepository
          .getEventsFromLocalDB(EventType.china.toCountryCode());
    } else {
      getChinaEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getHongKongEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.hongKong)) {
      getHongKongEvents = calendarEventRepository
          .getEventsFromLocalDB(EventType.hongKong.toCountryCode());
    } else {
      getHongKongEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getJapanEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.japan)) {
      getJapanEvents = calendarEventRepository
          .getEventsFromLocalDB(EventType.japan.toCountryCode());
    } else {
      getJapanEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getUkEvents;
    if (calendarEventRepository.getDisplayEventType().contains(EventType.uk)) {
      getUkEvents = calendarEventRepository
          .getEventsFromLocalDB(EventType.uk.toCountryCode());
    } else {
      getUkEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getUsEvents;
    if (calendarEventRepository.getDisplayEventType().contains(EventType.usa)) {
      getUsEvents = calendarEventRepository
          .getEventsFromLocalDB(EventType.usa.toCountryCode());
    } else {
      getUsEvents = Future.value(List.empty());
    }

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

    Future.wait([
      getTaiwanEvents,
      getChinaEvents,
      getHongKongEvents,
      getJapanEvents,
      getUkEvents,
      getUsEvents,
      getLunarEvents,
      getSolarEvents,
      getCustomEvents
    ]).then((allCountryEvents) {
      for (var events in allCountryEvents) {
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

  // refresh data
  Future<void> refreshGoogleCalendarHolidays() async {
    final List<CalendarEvent> originCombinedCalendarEvents =
        state.events.toList();

    Future<List<EventModel>> getTaiwanEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.taiwan)) {
      getTaiwanEvents =
          calendarEventRepository.getEvents(EventType.taiwan.toCountryCode());
    } else {
      getTaiwanEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getChinaEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.china)) {
      getChinaEvents =
          calendarEventRepository.getEvents(EventType.china.toCountryCode());
    } else {
      getChinaEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getHongKongEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.hongKong)) {
      getHongKongEvents =
          calendarEventRepository.getEvents(EventType.hongKong.toCountryCode());
    } else {
      getHongKongEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getJapanEvents;
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.japan)) {
      getJapanEvents =
          calendarEventRepository.getEvents(EventType.japan.toCountryCode());
    } else {
      getJapanEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getUkEvents;
    if (calendarEventRepository.getDisplayEventType().contains(EventType.uk)) {
      getUkEvents =
          calendarEventRepository.getEvents(EventType.uk.toCountryCode());
    } else {
      getUkEvents = Future.value(List.empty());
    }
    Future<List<EventModel>> getUsEvents;
    if (calendarEventRepository.getDisplayEventType().contains(EventType.uk)) {
      getUsEvents =
          calendarEventRepository.getEvents(EventType.usa.toCountryCode());
    } else {
      getUsEvents = Future.value(List.empty());
    }

    final allCountryEvents = await Future.wait([
      getTaiwanEvents,
      getChinaEvents,
      getHongKongEvents,
      getJapanEvents,
      getUkEvents,
      getUsEvents
    ]);

    for (var events in allCountryEvents) {
      if (events.isNotEmpty) {
        debugPrint('[Tony] getEvents, ${events.first.eventType.name} updated');
        // remove old event-type data
        originCombinedCalendarEvents.removeWhere(
            (element) => element.eventID == events.first.eventType.name);

        // add new event-type data
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
    debugPrint('[Tony] getEvents, allCountryEvents updated');
    emit(HomeState.success(originCombinedCalendarEvents));
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

  void refreshFromSettings() async {
    // TODO determine by custom tab diff
  }

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
