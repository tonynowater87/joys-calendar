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
      print('[Tony] UpdateDateTimeEvent $event');
      emit.call(state.copyWith(dateTime: event.memoDateTime));
    });

    on<UpdateMemoEvent>((event, emit) {
      print('[Tony] UpdateMemoEvent $event');
      emit.call(state.copyWith(memo: event.memo));
    });

    on<SaveEvent>((event, emit) {
      print('[Tony] SaveEvent $event');
      localMemoRepository.saveMemo(state.memoModel);
    });
  }
}
