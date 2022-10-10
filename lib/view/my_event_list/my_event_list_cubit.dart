import 'package:bloc/bloc.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_state.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_ui_model.dart';

class MyEventListCubit extends Cubit<MyEventListState> {
  LocalDatasource localDatasource;
  var checkedCount = 0;

  MyEventListCubit(this.localDatasource)
      : super(const MyEventListState.loading());

  List<MyEventUIModel> _getMyEventList() {
    var allMemos = localDatasource.getAllMemos();
    var myEventList = <MyEventUIModel>[];
    allMemos.asMap().forEach((key, value) {
      myEventList.add(MyEventUIModel(
          key: value.key,
          memo: value.memo,
          dateTime: value.dateTime,
          isChecked: false));
    });
    return myEventList;
  }

  void load() {
    emit(MyEventListState.loaded(_getMyEventList()));
  }

  void startDeleting() {
    emit(MyEventListState.deleting(state.myEventList, checkedCount));
  }

  void cancelDeleting() {
    checkedCount = 0;
    emit(MyEventListState.loaded(_getMyEventList()));
  }

  Future<void> delete() async {
    for (var element in state.myEventList) {
      if (element.isChecked) {
        await localDatasource.deleteMemo(element.key);
      }
    }
    emit(MyEventListState.loaded(_getMyEventList()));
  }

  void updateChecked(int index, bool isChecked) {
    if (isChecked) {
      checkedCount++;
    } else {
      checkedCount--;
    }
    var list = state.myEventList.toList();
    list[index] = list[index].copyWith(isChecked);
    emit(MyEventListState.deleting(list, checkedCount));
  }
}
