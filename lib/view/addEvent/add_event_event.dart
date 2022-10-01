part of 'add_event_bloc.dart';

abstract class AddEventEvent {}

class InitialEvent extends AddEventEvent {
  int? memoIndex;

  InitialEvent(this.memoIndex);
}

class UpdateDateTimeEvent extends AddEventEvent {
  late DateTime memoDateTime;

  UpdateDateTimeEvent(this.memoDateTime);
}

class UpdateMemoEvent extends AddEventEvent {
  late String memo;

  UpdateMemoEvent(this.memo);
}

class SaveDateTimeEvent extends AddEventEvent {}
