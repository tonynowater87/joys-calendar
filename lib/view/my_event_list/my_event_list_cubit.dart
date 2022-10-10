import 'package:bloc/bloc.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_state.dart';

class MyEventListCubit extends Cubit<MyEventListState> {
  LocalDatasource localDatasource;

  MyEventListCubit(this.localDatasource)
      : super(const MyEventListState.loading());

  void load() {
    var allMemos = localDatasource.getAllMemos();
    emit(MyEventListState.loaded(allMemos));
  }

  void startDeleting() {
    emit(MyEventListState.deleting(state.myEventList));
  }

  void cancelDeleting() {
    emit(MyEventListState.loaded(state.myEventList));
  }

  void delete() {
    // TODO
  }
}
