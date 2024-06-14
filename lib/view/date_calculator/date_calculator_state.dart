part of 'date_calculator_cubit.dart';

@immutable
abstract class DateCalculatorState {
  final DateModel startDate;

  const DateCalculatorState({
    required this.startDate,
  });

  String get resultTitle;

  String get result;

  List<CalendarEvent> get calcDaysEvents;

  DateTime get startDateDateTime => DateTime(startDate.toSolar().getYear(),
      startDate.toSolar().getMonth(), startDate.toSolar().getDay());
}

class DateCalculatorInterval extends DateCalculatorState {
  final DateModel? endDate;

  const DateCalculatorInterval({
    required DateModel startDate,
    required this.endDate,
  }) : super(startDate: startDate);

  @override
  String get result {
    if (endDate == null) {
      return "--";
    }
    final diff = endDate!.toSolar().subtract(startDate.toSolar());

    if (diff == 0) {
      return "兩個日期為同一天";
    }

    if (diff < 0) {
      return "結束日期早於開始日期";
    }

    var year = diff ~/ 365;
    var month = (diff % 365) ~/ 30;
    var day = (diff % 365) % 30;

    if (year > 0 && month > 0 && day > 0) {
      return "$year 年 $month 個月又 $day 天";
    }

    if (year > 0 && month > 0 && day == 0) {
      return "$year 年又 $month 個月";
    }

    if (year > 0 && month == 0 && day > 0) {
      return "$year 年又 $day 天";
    }

    if (year == 0 && month > 0 && day > 0) {
      return "$month 個月又 $day 天";
    }

    if (year > 0 && month == 0 && day == 0) {
      return "剛好 $year 年整";
    }

    if (year == 0 && month > 0 && day == 0) {
      return "剛好 $month 個月";
    }

    return "$day 天";
  }

  String get startDateString {
    if (startDate.isLunar) {
      return "農曆 ${startDate.toLunar()} (星期${startDate.toSolar().getWeekInChinese()})";
    } else {
      return "國曆 ${startDate.toSolar().toYmd()} (星期${startDate.toSolar().getWeekInChinese()})";
    }
  }

  String get endDateString {
    if (endDate == null) {
      return "--";
    }
    if (endDate!.isLunar) {
      return "農曆 ${endDate!.toLunar()} (星期${endDate!.toSolar().getWeekInChinese()})";
    } else {
      return "國曆 ${endDate!.toSolar().toYmd()} (星期${endDate!.toSolar().getWeekInChinese()})";
    }
  }

  @override
  String get resultTitle => endDate != null ? "兩個日期的間隔" : "請選擇結束日期";

  @override
  List<CalendarEvent> get calcDaysEvents {
    if (endDate == null) {
      return [
        CalendarEvent(
            eventName: '開始日期',
            eventDate: DateTime(
              startDate.toSolar().getYear(),
              startDate.toSolar().getMonth(),
              startDate.toSolar().getDay(),
            ),
            eventBackgroundColor:
                JoysCalendarThemeData.lightThemeData.colorScheme.primary,
            eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!.copyWith(fontSize: 8))
      ];
    }

    List<CalendarEvent> events = [];
    for (var i = 0; i <= endDate!.toSolar().subtract(startDate.toSolar()); i++) {
      events.add(CalendarEvent(
        eventDate: DateTime(startDate.toSolar().getYear(),
            startDate.toSolar().getMonth(), startDate.toSolar().getDay() + i),
        eventName: i == 0 ? '開始日期' : '第 $i 天',
        eventBackgroundColor:
            JoysCalendarThemeData.lightThemeData.colorScheme.primary,
        eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!.copyWith(fontSize: 8),
      ));
    }
    return events;
  }

  @override
  String toString() {
    return 'DateCalculatorInterval{startDate: $startDate, endDate: $endDate, calcDaysEvents: ${calcDaysEvents.length}}';
  }
}

class DateCalculatorAddition extends DateCalculatorState {
  final int addYearValue;
  final int addMonthValue;
  final int addDayValue;
  final int addWeekValue;

  DateCalculatorAddition({
    required DateModel startDate,
    required this.addYearValue,
    required this.addMonthValue,
    required this.addDayValue,
    required this.addWeekValue,
  }) : super(startDate: startDate);

  int get _totalAdditionDays {
    return addYearValue * 365 +
        addMonthValue * 30 +
        addWeekValue * 7 +
        addDayValue;
  }

  String get startDateString {
    if (startDate.isLunar) {
      return "農曆 ${startDate.toLunar()} (星期${startDate.toSolar().getWeekInChinese()})";
    } else {
      return "國曆 ${startDate.toSolar().toYmd()} (星期${startDate.toSolar().getWeekInChinese()})";
    }
  }

  @override
  String get result {
    var endSolarDate = startDate.toSolar().next(_totalAdditionDays);

    if (startDate.isLunar) {
      return "農曆 ${startDate.toLunar().next(_totalAdditionDays).toString()} (星期${endSolarDate.getWeekInChinese()})";
    } else {
      return "國曆 ${startDate.toSolar().next(_totalAdditionDays).toString()} (星期${endSolarDate.getWeekInChinese()})";
    }
  }

  @override
  String get resultTitle => "加上指定天數後的日期";

  DateTime get endDateDateTime {
    var endDate = startDate.toSolar().next(_totalAdditionDays);
    return DateTime(endDate.getYear(), endDate.getMonth(), endDate.getDay());
  }

  @override
  List<CalendarEvent> get calcDaysEvents {
    List<CalendarEvent> events = [];
    var endDate = startDate.toSolar().next(_totalAdditionDays);
    for (var i = 0; i <= endDate.subtract(startDate.toSolar()); i++) {
      events.add(CalendarEvent(
        eventDate: DateTime(startDate.toSolar().getYear(),
            startDate.toSolar().getMonth(), startDate.toSolar().getDay() + i),
        eventName: i == 0 ? '開始日期' : '加 $i 天',
        eventBackgroundColor:
            JoysCalendarThemeData.lightThemeData.colorScheme.primary,
        eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!.copyWith(fontSize: 8),
      ));
    }
    return events;
  }
}

class DateCalculatorSubtraction extends DateCalculatorState {
  final int subYearValue;
  final int subMonthValue;
  final int subDayValue;
  final int subWeekValue;

  DateCalculatorSubtraction({
    required DateModel startDate,
    required this.subYearValue,
    required this.subMonthValue,
    required this.subDayValue,
    required this.subWeekValue,
  }) : super(startDate: startDate);

  int get _totalSubtractionDays {
    return subYearValue * 365 +
        subMonthValue * 30 +
        subWeekValue * 7 +
        subDayValue;
  }

  String get startDateString {
    if (startDate.isLunar) {
      return "農曆 ${startDate.toLunar()} (星期${startDate.toSolar().getWeekInChinese()})";
    } else {
      return "國曆 ${startDate.toSolar().toYmd()} (星期${startDate.toSolar().getWeekInChinese()})";
    }
  }

  @override
  String get result {
    var endSolarDate = startDate.toSolar().next(-_totalSubtractionDays);

    if (startDate.isLunar) {
      return "農曆 ${startDate.toLunar().next(-_totalSubtractionDays)} (星期${endSolarDate.getWeekInChinese()})";
    } else {
      return "國曆 $endSolarDate (星期${endSolarDate.getWeekInChinese()})";
    }
  }

  DateTime get endDateDateTime {
    var endDate = startDate.toSolar().next(-_totalSubtractionDays);
    return DateTime(endDate.getYear(), endDate.getMonth(), endDate.getDay());
  }

  @override
  String get resultTitle => "減去指定天數後的日期";

  @override
  List<CalendarEvent> get calcDaysEvents {
    List<CalendarEvent> events = [];
    var endDate = startDate.toSolar().next(-_totalSubtractionDays);
    for (var i = startDate.toSolar().subtract(endDate); i >= 0; i--) {
      events.add(CalendarEvent(
        eventDate: DateTime(startDate.toSolar().getYear(),
            startDate.toSolar().getMonth(), startDate.toSolar().getDay() - i),
        eventName: i == 0 ? '開始日期' : '減 $i 天',
        eventBackgroundColor: JoysCalendarThemeData.lightThemeData.colorScheme.primary,
        eventTextStyle: JoysCalendarThemeData.calendarTextTheme.overline!.copyWith(fontSize: 8),
      ));
    }
    return events;
  }
}
