import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  late CalendarEventRepository calendarEventRepository;

  int _currentYear = DateTime.now().year;

  HomeCubit(this.calendarEventRepository) : super(const HomeState.loading());

  Future<void> getEvents() async {
    try {

      emit(const HomeState.loading());

      final List<CalendarEvent> combinedCalendarEvents = [];

      if (calendarEventRepository.getDisplayEventType().contains(EventType.lunar)) {
        var lunarEvents = await calendarEventRepository.getLunarEvents(_currentYear);
        combinedCalendarEvents.addAll(lunarEvents.map((e) =>
            CalendarEvent(
                eventName: e.eventName,
                eventDate: e.date,
                eventBackgroundColor: e.eventType.toEventColor())));
      }

      if (calendarEventRepository.getDisplayEventType().contains(EventType.solar)) {
        var solarEvents = await calendarEventRepository.getSolarEvents(_currentYear);
        combinedCalendarEvents.addAll(solarEvents.map((e) =>
            CalendarEvent(
                eventName: e.eventName,
                eventDate: e.date,
                eventBackgroundColor: e.eventType.toEventColor())));
      }

      Future<List<EventModel>> getTaiwanEvents;
      if (calendarEventRepository.getDisplayEventType().contains(EventType.taiwan)) {
        getTaiwanEvents = calendarEventRepository.getEvents(EventType.taiwan.toCountryCode());
      } else {
        getTaiwanEvents = Future.value(List.empty());
      }
      Future<List<EventModel>> getChinaEvents;
      if (calendarEventRepository.getDisplayEventType().contains(EventType.china)) {
        getChinaEvents = calendarEventRepository.getEvents(EventType.china.toCountryCode());
      } else {
        getChinaEvents = Future.value(List.empty());
      }
      Future<List<EventModel>> getHongKongEvents;
      if (calendarEventRepository.getDisplayEventType().contains(EventType.hongKong)) {
        getHongKongEvents = calendarEventRepository.getEvents(EventType.hongKong.toCountryCode());
      } else {
        getHongKongEvents = Future.value(List.empty());
      }
      Future<List<EventModel>> getJapanEvents;
      if (calendarEventRepository.getDisplayEventType().contains(EventType.japan)) {
        getJapanEvents = calendarEventRepository.getEvents(EventType.japan.toCountryCode());
      } else {
        getJapanEvents = Future.value(List.empty());
      }
      Future<List<EventModel>> getUkEvents;
      if (calendarEventRepository.getDisplayEventType().contains(EventType.uk)) {
        getUkEvents = calendarEventRepository.getEvents(EventType.uk.toCountryCode());
      } else {
        getUkEvents = Future.value(List.empty());
      }
      Future<List<EventModel>> getUsEvents;
      if (calendarEventRepository.getDisplayEventType().contains(EventType.uk)) {
        getUsEvents = calendarEventRepository.getEvents(EventType.usa.toCountryCode());
      } else {
        getUsEvents = Future.value(List.empty());
      }

      final allCountryEvents = await Future.wait(
          [getTaiwanEvents, getChinaEvents, getHongKongEvents, getJapanEvents, getUkEvents, getUsEvents]);

      for (var events in allCountryEvents) {
        combinedCalendarEvents.addAll(events.map((e) => CalendarEvent(
            eventName: e.eventName,
            eventDate: e.date,
            eventBackgroundColor: e.eventType.toEventColor())));
      }

      emit(HomeState.success(combinedCalendarEvents));
    } on Exception {
      emit(const HomeState.failure());
    }
  }

  void refreshFromSettings() {
    // TODO
  }
}
