import 'package:bloc/bloc.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:lunar/lunar.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {

  static const platformOpenCC = MethodChannel('joyscalendar.opencc');

  late CalendarEventRepository calendarEventRepository;

  int _currentYear = DateTime.now().year;

  HomeCubit(this.calendarEventRepository)
      : super(const HomeState.loading());

  Future<void> getEvents() async {
    try {
      emit(const HomeState.loading());

      final List<CalendarEvent> combinedCalendarEvents = [];

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

      if (calendarEventRepository
          .getDisplayEventType()
          .contains(EventType.lunar)) {
        var lunarEvents =
            await calendarEventRepository.getLunarEvents(_currentYear);
        combinedCalendarEvents.addAll(lunarEvents.map((e) => CalendarEvent(
            eventName: e.eventName,
            eventDate: e.date,
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!,
            order: -1)));
      }

      if (calendarEventRepository
          .getDisplayEventType()
          .contains(EventType.solar)) {
        var solarEvents =
            await calendarEventRepository.getSolarEvents(_currentYear);
        combinedCalendarEvents.addAll(solarEvents.map((e) => CalendarEvent(
            eventName: e.eventName,
            eventDate: e.date,
            eventBackgroundColor: e.eventType.toEventColor(),
            eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!)));
      }

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
            eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!)));
      }

      emit(HomeState.success(combinedCalendarEvents));
    } on Exception {
      emit(const HomeState.failure());
    }
  }

  void refreshFromSettings() {
    // TODO
  }

  Future<void> convertDateTitle(DateTime? datetime) async {
    //print('[Tony] convert datetime=$datetime');
    final dateString =
    DateFormat('y MMMM', AppConstants.defaultLocale)
        .format(datetime!);
    Lunar lunar = Lunar.fromDate(datetime);
    final ganZhi = await _convert(lunar.getYearInGanZhi());
    final shenXiao = await _convert(lunar.getYearShengXiao());
    final currentEvent = state.events;
    emit(HomeState.title(currentEvent, "$dateString $ganZhi $shenXiao"));
  }


  Future<String> _convert(String input) async {
    String output;
    try {
      output = await platformOpenCC
          .invokeMethod("convertToTraditionalChinese", <String, String>{"input": input});
    } on PlatformException catch (e) {
      output = "轉換失敗";
    }
    //print('[Tony] convert input=$input, output=$output');
    return output;
  }
}
