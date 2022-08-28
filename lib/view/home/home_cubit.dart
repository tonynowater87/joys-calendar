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
      final List<CalendarEvent> combinedCalendarEvents = [];
      var lunarEvents =
          await calendarEventRepository.getLunarEvents(_currentYear);
      combinedCalendarEvents.addAll(lunarEvents.map((e) => CalendarEvent(
          eventName: e.eventName,
          eventDate: e.date,
          eventBackgroundColor: e.eventType.toEventColor())));

      var getTaiwanEvents =
          calendarEventRepository.getEvents(EventType.taiwan.toCountryCode());
      var getJapanEvents =
          calendarEventRepository.getEvents(EventType.japan.toCountryCode());
      var getUkEvents =
          calendarEventRepository.getEvents(EventType.uk.toCountryCode());
      var getUsEvents =
          calendarEventRepository.getEvents(EventType.usa.toCountryCode());

      final allCountryEvents = await Future.wait(
          [getTaiwanEvents, getJapanEvents, getUkEvents, getUsEvents]);

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
