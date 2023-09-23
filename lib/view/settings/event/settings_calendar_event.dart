import 'package:joys_calendar/repo/model/event_model.dart';

abstract class SettingsCalendarEvent {}

class LoadStarted extends SettingsCalendarEvent {

}

class AddFilterEvent extends SettingsCalendarEvent {
  late EventType eventType;

  AddFilterEvent({
    required this.eventType,
  });
}

class RemoveFilterEvent extends SettingsCalendarEvent {
  late EventType eventType;

  RemoveFilterEvent({
    required this.eventType,
  });
}
