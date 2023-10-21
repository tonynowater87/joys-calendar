import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:joys_calendar/view/add/adding_event_type.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';

part 'adding_event_event.dart';

part 'adding_event_state.dart';

class AddingEventBloc extends Bloc<AddingEventEvent, AddingEventState> {
  AddingEventBloc(DateTime dateTime)
      : super(AddingEventState(
            DateModel(
                year: dateTime.year, month: dateTime.month, day: dateTime.day),
            AddingEventType.memo,
            "",
            false)) {
    on<AddingEventLoad>((event, emit) {
      debugPrint('[Tony] AddingEventLoad ${event.dateTime}');
      emit.call(AddingEventState(
          DateModel(
              year: dateTime.year, month: dateTime.month, day: dateTime.day),
          AddingEventType.memo,
          "",
          false));
    });

    on<AddingEventChangeType>((event, emit) {
      debugPrint('[Tony] AddingEventChangeType ${event.eventType}');
      emit.call(state.copyWith(eventType: event.eventType));
    });

    on<AddingEventChangeDate>((event, emit) {
      // TODO parse the time
      debugPrint(
          '[Tony] AddingEventChangeDate ${event.dateModel}, ${event.isLunar}');
      emit.call(state.copyWith(dateTime: event.dateModel, isLunar: event.isLunar));
    });

    on<AddingEventChangeContent>((event, emit) {
      debugPrint('[Tony] AddingEventChangeContent ${event.content}');
      emit.call(state.copyWith(content: event.content));
    });

    on<AddingEventSubmit>((event, emit) {
      // TODO save to database
    });
  }
}
