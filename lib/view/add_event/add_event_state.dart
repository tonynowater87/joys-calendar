part of 'add_event_bloc.dart';

enum AddEventStatus { add, edit }

class AddEventState extends Equatable {
  late MemoModel memoModel;
  late AddEventStatus status;

  AddEventState(this.memoModel, this.status);

  AddEventState.add() {
    status = AddEventStatus.add;
    var now = DateTime.now();
    memoModel = MemoModel()
      ..dateTime = DateTime(now.year, now.month, now.day)
      ..dateString = DateFormat(AppConstants.memoDateFormat).format(now)
      ..memo = "";
  }

  AddEventState.edit(this.memoModel) {
    status = AddEventStatus.edit;
  }

  AddEventState copyWith({DateTime? dateTime, String? memo}) {
    if (dateTime != null) {
      return AddEventState(
          MemoModel()
            ..dateTime = dateTime
            ..dateString = DateFormat(AppConstants.memoDateFormat).format(dateTime)
            ..memo = memoModel.memo,
          status);
    }
    if (memo != null) {
      return AddEventState(
          MemoModel()
            ..dateTime = memoModel.dateTime
            ..dateString = memoModel.dateString
            ..memo = memo,
          status);
    }
    throw Exception("not expected case");
  }

  @override
  List<Object?> get props => [status, memoModel];
}
