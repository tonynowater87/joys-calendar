import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

part 'add_event_event.dart';

part 'add_event_state.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  LocalDatasource localMemoRepository;
  dynamic? key;
  String updatedMemo = "";

  AddEventBloc(this.localMemoRepository) : super(AddEventState.add()) {
    on<ChangeDateTimeEvent>((event, emit) {
      emit.call(state.copyWith(dateTime: event.memoDateTime));
    });

    on<UpdateMemoEvent>((event, emit) {
      updatedMemo = event.memo;
    });

    on<AddDateTimeEvent>((event, emit) {
      key = null;
      updatedMemo = "";
      emit.call(AddEventState.add());
    });

    on<EditDateTimeEvent>((event, emit) {
      final memoModel = localMemoRepository.getMemo(event.key);
      updatedMemo = memoModel.memo;
      key = memoModel.key;
      emit.call(AddEventState.edit(memoModel));
    });
  }

  Future<bool> saveEvent() async {
    if (updatedMemo.isEmpty) {
      return false;
    }
    var updatedMemoModel = state.memoModel..memo = updatedMemo;
    if (key != null) {
      final memoModel = localMemoRepository.getMemo(key);
      await localMemoRepository.saveMemo(memoModel
        ..memo = updatedMemoModel.memo
        ..dateTime = updatedMemoModel.dateTime);
      return true;
    } else {
      await localMemoRepository.saveMemo(updatedMemoModel);
      return true;
    }
  }

  Future<void> delete() async {
    await localMemoRepository.deleteMemo(key);
  }
}
