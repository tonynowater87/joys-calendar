import 'package:bloc/bloc.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';
import 'package:meta/meta.dart';

part 'add_event_event.dart';
part 'add_event_state.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  LocalDatasource localMemoRepository;
  late MemoModel currentMemo;

  AddEventBloc(this.localMemoRepository) : super(AddEventLoading()) {

    on<InitialEvent>((event, emit) {

    });

    on<UpdateDateTimeEvent>((event, emit) {

    });

    on<UpdateMemoEvent>((event, emit) {

    });

    on<SaveDateTimeEvent>((event, emit) {
      localMemoRepository.saveMemo(currentMemo);
    });
  }
}
