import 'package:hive/hive.dart';

part 'calendar_model.g.dart';

@HiveType(typeId: 2)
class CalendarModel extends HiveObject {
  static const String boxKey = 'google_calendar_event';

  @HiveField(0)
  late String displayName;

  @HiveField(1)
  late DateTime dateTime;

  @HiveField(2)
  late String country;

  @HiveField(3)
  late int continuousDays;

  @override
  String toString() {
    return 'CalendarModel{key:$key, displayName: $displayName, dateTime: $dateTime, country: $country, continuousDays: $continuousDays}';
  }
}