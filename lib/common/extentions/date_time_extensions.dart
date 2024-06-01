import 'package:lunar/calendar/Lunar.dart';

extension DateTimeExtensions on DateTime {
  String get yearOfRoc {
    if (year - 1911 >= 0) {
      return "民國 ${year - 1911}年";
    }
    return "";
  }

  String get ganZhi {
    return Lunar.fromDate(this).getYearInGanZhi();
  }

  String get shenXiao {
    return Lunar.fromDate(this).getYearShengXiao();
  }

  String get lunarMonth {
    return Lunar.fromDate(this).getMonthInChinese();
  }

  String get lunarDay {
    return Lunar.fromDate(this).getDayInChinese();
  }

  bool isSameMonth(DateTime? other) {
    return year == other?.year && month == other?.month;
  }
}
