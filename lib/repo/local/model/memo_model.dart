import 'package:hive_flutter/hive_flutter.dart';

part 'memo_model.g.dart';

@HiveType(typeId: 1)
class MemoModel extends HiveObject {
  static const String boxKey = 'memo';

  @HiveField(0)
  late String memo;

  @HiveField(1)
  late DateTime dateTime; // [yyyy, mm, dd];

  @override
  String toString() {
    return 'MemoModel{key:$key, memo: $memo, dateTime: $dateTime}';
  }

  static Map<String, dynamic> toJson(MemoModel value) =>
         {'memo': value.memo, 'dateTime': value.dateTime.millisecondsSinceEpoch};

  static MemoModel fromJson(Map<String, dynamic> json) {
    return MemoModel()
      ..memo = json['memo'] ?? ''
      ..dateTime = DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int);
  }
}
