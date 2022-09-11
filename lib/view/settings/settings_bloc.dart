import 'package:bloc/bloc.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/settings/settings_event.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';
import 'package:joys_calendar/view/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  late List<SettingsEventItem> settingsEventItems;
  late CalendarEventRepository calendarEventRepository;

  SettingsBloc(this.calendarEventRepository) : super(SettingsState.initial()) {
    on<LoadStarted>(_initSettingEventItems);
    on<AddFilterEvent>((event, emit) {});
    on<RemoveFilterEvent>((event, emit) {});
  }

  _initSettingEventItems(SettingsEvent event, Emitter<SettingsState> emitter) {
    List<EventType> currentEventTypes =
        calendarEventRepository.getDisplayEventType();

    settingsEventItems = List.generate(
        EventType.values.length,
        (index) => SettingsEventItem(
            EventType.values[index],
            currentEventTypes
                .any((element) => EventType.values[index] == element)));
    emitter(
        state.copyWith(settingsEventItems.toList(), SettingsStateStatus.ready));
  }
}
