part of 'add_event_bloc.dart';

abstract class AddEventEvent {}

class AddDateTimeEvent extends AddEventEvent {
  AddDateTimeEvent();
}

class EditDateTimeEvent extends AddEventEvent {
  dynamic key;

  EditDateTimeEvent(this.key);
}

class UpdateDateTimeEvent extends AddEventEvent {
  DateTime memoDateTime;

  UpdateDateTimeEvent(this.memoDateTime);
}

class UpdateMemoEvent extends AddEventEvent {
  String memo;

  UpdateMemoEvent(this.memo);
}
