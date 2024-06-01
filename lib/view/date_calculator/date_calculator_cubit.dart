import 'package:bloc/bloc.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/common/utils/class_utils.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';

part 'date_calculator_state.dart';

class DateCalculatorCubit extends Cubit<DateCalculatorState> {
  DateCalculatorCubit(DateTime now)
      : super(DateCalculatorInterval(
            startDate: DateModel(
                year: now.year, month: now.month, day: now.day, isLunar: false),
            endDate: null));

  void changeToInterval({
    required DateModel startDate,
    DateModel? endDate,
  }) =>
      emit(DateCalculatorInterval(startDate: startDate, endDate: endDate));

  void changeToAddition({
    DateModel? startDate,
    int? addYearValue,
    int? addMonthValue,
    int? addDayValue,
    int? addWeekValue,
  }) {
    var stateAddYearValue =
        ClassUtils.tryCast<DateCalculatorAddition>(state)?.addYearValue;
    var stateAddMonthValue =
        ClassUtils.tryCast<DateCalculatorAddition>(state)?.addMonthValue;
    var stateAddDayValue =
        ClassUtils.tryCast<DateCalculatorAddition>(state)?.addDayValue;
    var stateAddWeekValue =
        ClassUtils.tryCast<DateCalculatorAddition>(state)?.addWeekValue;

    if (startDate != null) {
      emit(DateCalculatorAddition(
          startDate: startDate,
          addYearValue: stateAddYearValue ?? 0,
          addMonthValue: stateAddMonthValue ?? 0,
          addDayValue: stateAddDayValue ?? 0,
          addWeekValue: stateAddWeekValue ?? 0));
      return;
    }

    emit(DateCalculatorAddition(
        startDate: state.startDate,
        addYearValue: addYearValue ?? stateAddYearValue ?? 0,
        addMonthValue: addMonthValue ?? stateAddMonthValue ?? 0,
        addDayValue: addDayValue ?? stateAddDayValue ?? 0,
        addWeekValue: addWeekValue ?? stateAddWeekValue ?? 0));
  }

  void changeToSubtraction({
    DateModel? startDate,
    int? subYearValue,
    int? subMonthValue,
    int? subDayValue,
    int? subWeekValue,
  }) {
    var stateSubYearValue =
        ClassUtils.tryCast<DateCalculatorSubtraction>(state)?.subYearValue;
    var stateSubMonthValue =
        ClassUtils.tryCast<DateCalculatorSubtraction>(state)?.subMonthValue;
    var stateSubDayValue =
        ClassUtils.tryCast<DateCalculatorSubtraction>(state)?.subDayValue;
    var stateSubWeekValue =
        ClassUtils.tryCast<DateCalculatorSubtraction>(state)?.subWeekValue;

    if (startDate != null) {
      emit(DateCalculatorSubtraction(
          startDate: startDate,
          subYearValue: stateSubYearValue ?? 0,
          subMonthValue: stateSubMonthValue ?? 0,
          subDayValue: stateSubDayValue ?? 0,
          subWeekValue: stateSubWeekValue ?? 0));
      return;
    }

    emit(DateCalculatorSubtraction(
        startDate: state.startDate,
        subYearValue: subYearValue ?? stateSubYearValue ?? 0,
        subMonthValue: subMonthValue ?? stateSubMonthValue ?? 0,
        subDayValue: subDayValue ?? stateSubDayValue ?? 0,
        subWeekValue: subWeekValue ?? stateSubWeekValue ?? 0));
  }
}
