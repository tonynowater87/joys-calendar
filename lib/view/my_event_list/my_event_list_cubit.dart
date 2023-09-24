import 'package:bloc/bloc.dart';
import 'package:joys_calendar/common/extentions/notify_id_extensions.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_state.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_ui_model.dart';

class MyEventListCubit extends Cubit<MyEventListState> {
  LocalDatasource localDatasource;
  SharedPreferenceProvider sharedPreferenceProvider;
  LocalNotificationProvider localNotificationProvider;
  var checkedCount = 0;

  MyEventListCubit(this.localDatasource, this.sharedPreferenceProvider,
      this.localNotificationProvider)
      : super(const MyEventListState.loading());

  List<MyEventUIModel> _getMyEventList() {
    DateTime? dateTime;
    var allMemos = localDatasource.getAllMemos();
    var myEventList = <MyEventUIModel>[];
    if (allMemos.isEmpty) {
      return myEventList;
    }

    int? year;
    allMemos.asMap().forEach((key, value) {
      if (year != value.dateTime.year) {
        year = value.dateTime.year;
        myEventList.add(MyEventUIModel(
            key: -2, memo: "", dateTime: value.dateTime, isChecked: false));
      }

      if (dateTime?.toIso8601String() != value.dateTime.toIso8601String()) {
        myEventList.add(MyEventUIModel(
            key: -1, memo: "", dateTime: value.dateTime, isChecked: false));
      }
      myEventList.add(MyEventUIModel(
          key: value.key,
          memo: value.memo,
          dateTime: value.dateTime,
          isChecked: false));

      dateTime = value.dateTime;
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
        if (sharedPreferenceProvider.isMemoNotifyEnable()) {
          var memoModel = localDatasource.getMemo(element.key);
          localNotificationProvider.cancelNotification(memoModel.getNotifyId());
        }
        await localDatasource.deleteMemo(element.key);
      }
    }
    checkedCount = 0;
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
