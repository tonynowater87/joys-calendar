import 'package:bloc/bloc.dart';
import 'package:joys_calendar/common/extentions/event_model_extensions.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:joys_calendar/view/settings/event/settings_calendar_event.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';
import 'package:joys_calendar/view/settings/settings_state.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsCalendarBloc extends Bloc<SettingsCalendarEvent, SettingsState> {
  late List<SettingsEventItem> settingsEventItems;
  late CalendarEventRepository calendarEventRepository;
  late SharedPreferenceProvider sharedPreferenceProvider;
  late LocalNotificationProvider localNotificationProvider;

  SettingsCalendarBloc(this.calendarEventRepository,
      this.sharedPreferenceProvider, this.localNotificationProvider)
      : super(const SettingsState.initial()) {
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
    emitter.call(state.copyWith(settingsEventItems.toList()));
  }

  _addSettingEventItems(
      AddFilterEvent event, Emitter<SettingsState> emitter) async {
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
      var calendarEvents = await calendarEventRepository
          .getFutureEventsFromLocalDB(event.eventType.toCountryCode());
      for (var event in calendarEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.showNotification(id, event.eventName, null,
            tz.TZDateTime.from(event.date, tz.local));
      }
    }

    if (isPermissionGranted &&
        sharedPreferenceProvider.isSolarNotifyEnable() &&
        event.eventType == EventType.solar) {
      var futureSolarEvents =
          await calendarEventRepository.getFutureSolarEvents();
      for (var event in futureSolarEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.showNotification(id, event.eventName, null,
            tz.TZDateTime.from(event.date, tz.local));
      }
    }

    if (isPermissionGranted &&
        sharedPreferenceProvider.isMemoNotifyEnable() &&
        event.eventType == EventType.custom) {
      var futureCustomEvents =
          await calendarEventRepository.getFutureCustomEvents();
      for (var event in futureCustomEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.showNotification(id, event.eventName, null,
            tz.TZDateTime.from(event.date, tz.local));
      }
    }

    await _update();
    emitter.call(state.copyWith(settingsEventItems.toList()));
  }

  _removeSettingEventItems(
      RemoveFilterEvent event, Emitter<SettingsState> emitter) async {
    settingsEventItems[settingsEventItems
            .indexWhere((element) => element.eventType == event.eventType)] =
        SettingsEventItem(event.eventType, false);

    if (event.eventType == EventType.solar &&
        sharedPreferenceProvider.isSolarNotifyEnable()) {
      var futureSolarEvents =
          await calendarEventRepository.getFutureSolarEvents();
      for (var event in futureSolarEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.cancelNotification(id);
      }
    }

    if (event.eventType == EventType.custom &&
        sharedPreferenceProvider.isMemoNotifyEnable()) {
      var futureCustomEvents =
          await calendarEventRepository.getFutureCustomEvents();
      for (var event in futureCustomEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.cancelNotification(id);
      }
    }

    if (sharedPreferenceProvider.isCalendarNotifyEnable() &&
        event.eventType != EventType.solar &&
        event.eventType != EventType.lunar &&
        event.eventType != EventType.custom) {
      var futureCalendarEvents = await calendarEventRepository
          .getFutureEventsFromLocalDB(event.eventType.toCountryCode());
      for (var event in futureCalendarEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.cancelNotification(id);
      }
    }

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
