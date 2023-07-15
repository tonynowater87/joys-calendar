import 'package:bloc/bloc.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/settings/settings_event.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';
import 'package:joys_calendar/view/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  late List<SettingsEventItem> settingsEventItems;
  late CalendarEventRepository calendarEventRepository;

  SettingsBloc(this.calendarEventRepository) : super(const SettingsState.initial()) {
    on<LoadStarted>(_initSettingEventItems);
    on<AddFilterEvent>(_addSettingEventItems);
    on<RemoveFilterEvent>(_removeSettingEventItems);
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
    emitter.call(state.copyWith(settingsEventItems.toList()));
  }

  _addSettingEventItems(AddFilterEvent event, Emitter<SettingsState> emitter) async {
    settingsEventItems[settingsEventItems
            .indexWhere((element) => element.eventType == event.eventType)] =
        SettingsEventItem(event.eventType, true);
    await _update();
    emitter.call(state.copyWith(settingsEventItems.toList()));
  }

  _removeSettingEventItems(
      RemoveFilterEvent event, Emitter<SettingsState> emitter) async {
    settingsEventItems[settingsEventItems
            .indexWhere((element) => element.eventType == event.eventType)] =
        SettingsEventItem(event.eventType, false);
    await _update();
    emitter.call(state.copyWith(settingsEventItems.toList()));
  }

  Future<void> _update() async {
    await calendarEventRepository.setDisplayEventType(settingsEventItems
        .where((element) => element.isSelected)
        .map((e) => e.eventType)
        .toList());
  }
}
