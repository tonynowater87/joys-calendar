import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

enum MyEventListStatus { loading, loaded, deleting }

class MyEventListState extends Equatable {
  final List<MemoModel> myEventList;
  final List<bool> checkedList;
  final MyEventListStatus myEventListStatus;

  const MyEventListState._(
      {this.myEventList = const <MemoModel>[],
      this.checkedList = const <bool>[],
      this.myEventListStatus = MyEventListStatus.loading});

  const MyEventListState.loading() : this._();

  const MyEventListState.loaded(List<MemoModel> myEventList)
      : this._(
            myEventList: myEventList,
            myEventListStatus: MyEventListStatus.loaded);

  const MyEventListState.deleting(List<MemoModel> myEventList)
      : this._(myEventList: myEventList, myEventListStatus: MyEventListStatus.deleting);

  @override
  List<Object?> get props => [myEventListStatus, myEventList];
}
