import 'package:hive_flutter/hive_flutter.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

class LocalDatasourceImpl extends LocalDatasource {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter<MemoModel>(MemoModelAdapter());
    await Hive.openBox<MemoModel>(MemoModel.boxKey);
  }

  @override
  Future<List<MemoModel>> getMemos(DateTime dateTime) async {
    final box = Hive.box(MemoModel.boxKey);
    return List<MemoModel>.generate(
            box.values.length, (index) => box.getAt(index))
        .where((element) => element.dateTime == dateTime)
        .whereType<MemoModel>()
        .toList();
  }

  @override
  Future<void> saveMemo(DateTime dateTime, String memo) {
    return Hive.box<MemoModel>(MemoModel.boxKey).add(MemoModel()
      ..dateTime = dateTime
      ..memo = memo);
  }

  @override
  Future<bool> hasMemo(DateTime dateTime) async {
    final box = Hive.box(MemoModel.boxKey);
    return box.isNotEmpty;
  }
}
