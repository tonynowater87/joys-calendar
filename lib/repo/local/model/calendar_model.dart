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

  @HiveField(3, defaultValue: 0)
  late int continuousDays;

  static CalendarModel fromJson(Map<String, dynamic> json) {
    CalendarModel model = CalendarModel()
      ..displayName = json['displayName'] ?? ''
      ..dateTime = DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int)
      ..country = json['country'] ?? ''
      ..continuousDays = json['continuousDays'] ?? 0;
    return model;
  }

  static Map<String, dynamic> toJson(CalendarModel model) {
    Map<String, dynamic> json = {
      'displayName': model.displayName,
      'dateTime': model.dateTime.millisecondsSinceEpoch,
      'country': model.country,
      'continuousDays': model.continuousDays,
    };
    return json;
  }
}
