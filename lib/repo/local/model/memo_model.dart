import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';

part 'memo_model.g.dart';

@HiveType(typeId: 1)
class MemoModel extends HiveObject {
  static const String boxKey = 'memo';

  @HiveField(0)
  late String memo;

  @HiveField(1)
  late DateTime dateTime; // [yyyy, mm, dd, hh, mm, ss]  (with timezone hour 0) deprecated

  @HiveField(2, defaultValue: '')
  late String dateString; // [yyyy/mm/dd];

  @override
  String toString() {
    return 'MemoModel{key:$key, memo: $memo, dateTime: $dateTime, dateString: $dateString}';
  }

  static Map<String, dynamic> toJson(MemoModel value) =>
      {
        'memo': value.memo,
        'dateTime': value.dateTime.millisecondsSinceEpoch,
        'dateString': value.dateString
      };

  static MemoModel fromJson(Map<String, dynamic> json) {
    DateTime? dateTime;
    String dateString;

    MemoModel model = MemoModel()..memo = json['memo'] ?? '';

    if (json.containsKey('dateTime')) {
      // old
      dateTime = DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int);
      dateString = DateFormat(AppConstants.memoDateFormat).format(dateTime);
      model.dateTime = dateTime;
      model.dateString = dateString;
    } else {
      // new
      dateString = json['dateString']!;
      model.dateTime = DateFormat(AppConstants.memoDateFormat).parse(dateString);
      model.dateString = dateString;
    }
    return model;
  }
}
