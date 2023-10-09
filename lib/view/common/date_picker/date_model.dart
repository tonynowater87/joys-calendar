import 'package:lunar/calendar/Lunar.dart';
import 'package:lunar/calendar/Solar.dart';

class DateModel {
  int year;
  int month;
  int? day;
  bool isLunar = false;

  DateModel(
      {required this.year,
        required this.month,
        required this.day,
        this.isLunar = false});

  Lunar toLunar() {
    if (isLunar) {
      return Lunar.fromYmd(year, month, day ?? 1);
    } else {
      return Solar.fromDate(DateTime(year, month, day ?? 1)).getLunar();
    }
  }

  Solar toSolar() {
    if (isLunar) {
      return Lunar.fromYmd(year, month, day ?? 1).getSolar();
    } else {
      return Solar.fromDate(DateTime(year, month, day ?? 1));
    }
  }

  @override
  String toString() {
    return 'DateModel{year: $year, month: $month, day: $day, isLunar: $isLunar}';
  }
}