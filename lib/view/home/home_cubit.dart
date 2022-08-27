import 'package:bloc/bloc.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  late CalendarEventRepository calendarEventRepository;

  HomeCubit(this.calendarEventRepository) : super(const HomeState.loading());

  Future<void> getEvents() async {
    try {
      var getTaiwanEvents =
          calendarEventRepository.getEvents(EventType.taiwan.toCountryCode());
      var getJapanEvents =
          calendarEventRepository.getEvents(EventType.japan.toCountryCode());
      var getUkEvents =
          calendarEventRepository.getEvents(EventType.uk.toCountryCode());
      var getUsEvents =
          calendarEventRepository.getEvents(EventType.us.toCountryCode());
      final allCountryEvents = await Future.wait(
          [getTaiwanEvents, getJapanEvents, getUkEvents, getUsEvents]);

      final List<CalendarEvent> combinedCalendarEvents = [];
      for (var events in allCountryEvents) {
        combinedCalendarEvents.addAll(events.map(
            (e) => CalendarEvent(eventName: e.eventName, eventDate: e.date)));
      }
      emit(HomeState.success(combinedCalendarEvents));
    } on Exception {
      emit(const HomeState.failure());
    }
  }
}
