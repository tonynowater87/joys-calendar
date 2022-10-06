import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

part 'add_event_event.dart';

part 'add_event_state.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  LocalDatasource localMemoRepository;

  AddEventBloc(this.localMemoRepository) : super(AddEventState.initial()) {
    on<UpdateDateTimeEvent>((event, emit) {
      emit.call(state.copyWith(dateTime: event.memoDateTime));
    });

    on<UpdateMemoEvent>((event, emit) {
      emit.call(state.copyWith(memo: event.memo));
    });
  }

  Future<void> saveEvent() async {
    await localMemoRepository.saveMemo(state.memoModel);
  }
}
