import 'package:joys_calendar/repo/model/event_model.dart';

abstract class SettingsEvent {}

class LoadStarted extends SettingsEvent {

}

class AddFilterEvent extends SettingsEvent {
  late EventType eventType;

  AddFilterEvent({
    required this.eventType,
  });
}

class RemoveFilterEvent extends SettingsEvent {
  late EventType eventType;

  RemoveFilterEvent({
    required this.eventType,
  });
}
