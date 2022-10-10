import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

part 'add_event_event.dart';

part 'add_event_state.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  LocalDatasource localMemoRepository;
  dynamic? key;

  AddEventBloc(this.localMemoRepository) : super(AddEventState.add()) {
    on<UpdateDateTimeEvent>((event, emit) {
      emit.call(state.copyWith(dateTime: event.memoDateTime));
    });

    on<UpdateMemoEvent>((event, emit) {
      emit.call(state.copyWith(memo: event.memo));
    });

    on<EditDateTimeEvent>((event, emit) {
      final memoModel = localMemoRepository.getMemo(event.key);
      key = memoModel.key;
      emit.call(AddEventState.edit(memoModel));
    });
  }

  Future<void> saveEvent() async {
    var updatedMemoModel = state.memoModel;
    if (key != null) {
      final memoModel = localMemoRepository.getMemo(key);
      await localMemoRepository.saveMemo(memoModel
        ..memo = updatedMemoModel.memo
        ..dateTime = updatedMemoModel.dateTime);
    } else {
      await localMemoRepository.saveMemo(updatedMemoModel);
    }
  }
}
