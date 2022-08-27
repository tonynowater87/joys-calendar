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
      List<EventModel> events =
          await calendarEventRepository.getEvents("zh-tw.taiwan");
      List<CalendarEvent> calendarEvents = events
          .map((e) => CalendarEvent(eventName: e.eventName, eventDate: e.date))
          .toList();
      emit(HomeState.success(calendarEvents));
    } on Exception {
      emit(const HomeState.failure());
    }
  }
}
