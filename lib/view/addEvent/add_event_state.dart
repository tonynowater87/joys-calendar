part of 'add_event_bloc.dart';

@immutable
abstract class AddEventState {}

class AddEventLoading extends AddEventState {}

class AddEventLoaded extends AddEventState {
  late String memo;

  AddEventLoaded(this.memo);
}
