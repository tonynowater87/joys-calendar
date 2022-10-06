import 'package:bloc/bloc.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_state.dart';

class MyEventListCubit extends Cubit<MyEventListState> {
  MyEventListCubit()
      : super(MyEventListState(
            myEventList: [], myEventListStatus: MyEventListStatus.loading));

  void load() {}
}
