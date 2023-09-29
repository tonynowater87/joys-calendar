import 'package:bloc/bloc.dart';
import 'package:joys_calendar/common/utils/notification_helper.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:joys_calendar/view/settings/event/settings_calendar_event.dart';
import 'package:joys_calendar/view/settings/event/settings_calendar_state.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';

class SettingsCalendarBloc extends Bloc<SettingsCalendarEvent, SettingsState> {
  late List<SettingsEventItem> settingsEventItems;
  late CalendarEventRepository calendarEventRepository;
  late SharedPreferenceProvider sharedPreferenceProvider;
  late LocalNotificationProvider localNotificationProvider;
  late NotificationHelper notificationHelper;

  SettingsCalendarBloc(
      this.calendarEventRepository,
      this.sharedPreferenceProvider,
      this.localNotificationProvider,
      this.notificationHelper)
      : super(SettingsState(settingEventItems: const [], isLoaded: false)) {
    on<LoadStarted>(_initSettingEventItems);
    on<AddFilterEvent>(_addSettingEventItems);
    on<RemoveFilterEvent>(_removeSettingEventItems);
  }

  _initSettingEventItems(
      SettingsCalendarEvent event, Emitter<SettingsState> emitter) {
    List<EventType> currentEventTypes =
        calendarEventRepository.getDisplayEventType();

    settingsEventItems = List.generate(
        EventType.values.length,
        (index) => SettingsEventItem(
            EventType.values[index],
            currentEventTypes
                .any((element) => EventType.values[index] == element)));
    emitter
        .call(state.copyWith(settingEventItems: settingsEventItems.toList()));
  }

  _addSettingEventItems(
      AddFilterEvent event, Emitter<SettingsState> emitter) async {
    emitter.call(state.copyWith(isLoaded: true));

    settingsEventItems[settingsEventItems
            .indexWhere((element) => element.eventType == event.eventType)] =
        SettingsEventItem(event.eventType, true);

    var isPermissionGranted =
        await localNotificationProvider.isPermissionGranted();
    if (isPermissionGranted &&
        sharedPreferenceProvider.isCalendarNotifyEnable() &&
        event.eventType != EventType.solar &&
        event.eventType != EventType.lunar &&
        event.eventType != EventType.custom) {
      notificationHelper.setCalendarNotify([event.eventType], true);
    }

    if (isPermissionGranted &&
        sharedPreferenceProvider.isSolarNotifyEnable() &&
        event.eventType == EventType.solar) {
      notificationHelper.setSolarNotify(true);
    }

    if (isPermissionGranted &&
        sharedPreferenceProvider.isMemoNotifyEnable() &&
        event.eventType == EventType.custom) {
      notificationHelper.setMemoNotify(true);
    }

    await _update();
    emitter.call(state.copyWith(
        settingEventItems: settingsEventItems.toList(), isLoaded: false));
  }

  _removeSettingEventItems(
      RemoveFilterEvent event, Emitter<SettingsState> emitter) async {
    emitter.call(state.copyWith(isLoaded: true));

    settingsEventItems[settingsEventItems
            .indexWhere((element) => element.eventType == event.eventType)] =
        SettingsEventItem(event.eventType, false);

    if (event.eventType == EventType.solar &&
        sharedPreferenceProvider.isSolarNotifyEnable()) {
      notificationHelper.setSolarNotify(false);
    }

    if (event.eventType == EventType.custom &&
        sharedPreferenceProvider.isMemoNotifyEnable()) {
      notificationHelper.setMemoNotify(false);
    }

    if (sharedPreferenceProvider.isCalendarNotifyEnable() &&
        event.eventType != EventType.solar &&
        event.eventType != EventType.lunar &&
        event.eventType != EventType.custom) {
      notificationHelper.setCalendarNotify([event.eventType], false);
    }

    await _update();
    emitter.call(state.copyWith(
        settingEventItems: settingsEventItems.toList(), isLoaded: false));
  }

  Future<void> _update() async {
    await calendarEventRepository.setDisplayEventType(settingsEventItems
        .where((element) => element.isSelected)
        .map((e) => e.eventType)
        .toList());
  }
}
