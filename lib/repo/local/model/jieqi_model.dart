import 'package:hive/hive.dart';

part 'jieqi_model.g.dart';

@HiveType(typeId: 3)
class JieQiModel extends HiveObject {
  static const String boxKey = 'jieQi';

  @HiveField(0)
  late String displayName;

  @HiveField(1)
  late DateTime dateTime;

  @override
  String toString() {
    return 'JieQiModel{key:$key, displayName: $displayName, dateTime: $dateTime}';
  }
}