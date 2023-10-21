part of 'adding_event_bloc.dart';

@immutable
abstract class AddingEventEvent {}

class AddingEventLoad extends AddingEventEvent {
  final DateTime dateTime;

  AddingEventLoad(this.dateTime);
}

class AddingEventChangeType extends AddingEventEvent {
  final AddingEventType eventType;

  AddingEventChangeType(this.eventType);
}

class AddingEventChangeDate extends AddingEventEvent {
  final DateModel dateModel;
  final bool isLunar;

  AddingEventChangeDate(this.dateModel, this.isLunar);
}

class AddingEventChangeContent extends AddingEventEvent {
  final String content;

  AddingEventChangeContent(this.content);
}

class AddingEventSubmit extends AddingEventEvent {}