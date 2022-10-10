import 'package:equatable/equatable.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_ui_model.dart';

enum MyEventListStatus { loading, loaded, deleting }

class MyEventListState extends Equatable {
  final List<MyEventUIModel> myEventList;
  final MyEventListStatus myEventListStatus;
  final int checkedCount;

  const MyEventListState._(
      {this.myEventList = const <MyEventUIModel>[],
      this.checkedCount = 0,
      this.myEventListStatus = MyEventListStatus.loading});

  const MyEventListState.loading() : this._();

  const MyEventListState.loaded(List<MyEventUIModel> myEventList)
      : this._(
            myEventList: myEventList,
            myEventListStatus: MyEventListStatus.loaded);

  const MyEventListState.deleting(
      List<MyEventUIModel> myEventList, int checkedCount)
      : this._(
            myEventList: myEventList,
            checkedCount: checkedCount,
            myEventListStatus: MyEventListStatus.deleting);

  @override
  List<Object?> get props => [myEventList, myEventListStatus];
}
