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
  List<MemoModel> getMemos(DateTime dateTime) {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    return List<MemoModel>.generate(
            box.values.length, (index) => box.getAt(index)!)
        .where((element) => element.dateTime == dateTime)
        .whereType<MemoModel>()
        .toList();
  }

  @override
  Future<void> saveMemo(MemoModel memoModel) {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    final existModel = Hive.box<MemoModel>(MemoModel.boxKey)
        .values
        .where((element) => element.key == memoModel.key);
    if (existModel.isEmpty) {
      return box.add(memoModel);
    } else {
      return box.put(memoModel.key, memoModel);
    }
  }

  @override
  Future<bool> hasMemo(DateTime dateTime) async {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    return box.isNotEmpty;
  }

  @override
  Future<void> deleteMemo(MemoModel memoModel) {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    return box.delete(memoModel);
  }

  @override
  MemoModel getMemo(dynamic key) {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    return box.get(key)!;
  }
}
