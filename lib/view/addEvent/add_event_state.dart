part of 'add_event_bloc.dart';

enum AddEventStatus { initial, update }

class AddEventState extends Equatable {
  late MemoModel memoModel;
  late AddEventStatus status;

  AddEventState(this.memoModel, this.status);

  AddEventState.initial() {
    status = AddEventStatus.initial;
    var now = DateTime.now();
    memoModel = MemoModel()
      ..dateTime = DateTime(now.year, now.month, now.day)
      ..memo = "";
  }

  AddEventState copyWith({DateTime? dateTime, String? memo}) {
    if (dateTime != null) {
      return AddEventState(
          MemoModel()
            ..dateTime = dateTime
            ..memo = memoModel.memo,
          AddEventStatus.update);
    }
    if (memo != null) {
      return AddEventState(
          MemoModel()
            ..dateTime = memoModel.dateTime
            ..memo = memo,
          AddEventStatus.update);
    }
    throw Exception("not expected case");
  }

  @override
  List<Object?> get props => [status, memoModel];
}
