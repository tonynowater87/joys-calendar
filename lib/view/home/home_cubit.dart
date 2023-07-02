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

  int _currentYear = DateTime.now().year;

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
    if (calendarEventRepository.getDisplayEventType().contains(EventType.uk)) {
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
      getSolarEvents = calendarEventRepository.getSolarEventsFromLocalDB(_currentYear);
    } else {
      getSolarEvents = Future.value(List.empty());
    }

    Future.wait([
      getTaiwanEvents,
      getChinaEvents,
      getHongKongEvents,
      getJapanEvents,
      getUkEvents,
      getUsEvents,
      getLunarEvents,
      getSolarEvents
    ]).then((allCountryEvents) {
      for (var events in allCountryEvents) {
        combinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            order: e.eventType == EventType.lunar ? -1 : e.eventType.index,
            eventName: e.eventName,
            eventDate: e.date,
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }
      debugPrint('[Tony] update all event ${DateTime.now()}');
      emit(HomeState.success(combinedCalendarEvents));
    });

    getEvents();
  }

  // refresh data
  Future<void> getEvents() async {
    try {
      final List<CalendarEvent> combinedCalendarEvents = [];

      await getCustomEvents(combinedCalendarEvents);
      await getLunarEvents(combinedCalendarEvents, 5);
      await getSolarEvents(combinedCalendarEvents);

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
        getHongKongEvents = calendarEventRepository
            .getEvents(EventType.hongKong.toCountryCode());
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
      if (calendarEventRepository
          .getDisplayEventType()
          .contains(EventType.uk)) {
        getUkEvents =
            calendarEventRepository.getEvents(EventType.uk.toCountryCode());
      } else {
        getUkEvents = Future.value(List.empty());
      }
      Future<List<EventModel>> getUsEvents;
      if (calendarEventRepository
          .getDisplayEventType()
          .contains(EventType.uk)) {
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
        combinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            eventName: e.eventName,
            eventDate: e.date,
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle:
                JoysCalendarThemeData.calendarTextTheme.overline!)));
      }

      debugPrint('[Tony] get all event ${DateTime.now()}');
      emit(HomeState.success(combinedCalendarEvents));
    } on Exception {
      emit(const HomeState.failure());
    }
  }

  Future<void> getSolarEvents(
      List<CalendarEvent> combinedCalendarEvents) async {
    if (calendarEventRepository
        .getDisplayEventType()
        .contains(EventType.solar)) {
      var solarEvents =
          await calendarEventRepository.getSolarEvents(_currentYear, 5);
      combinedCalendarEvents.addAll(solarEvents.map((e) => CalendarEvent(
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
          eventName: e.eventName,
          eventDate: e.date,
          eventBackgroundColor: e.eventType.toEventColor(),
          eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!)));
    }
  }

  void refreshFromSettings() {
    // TODO
  }
}
