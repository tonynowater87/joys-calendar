import 'package:hive_flutter/hive_flutter.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/calendar_model.dart';
import 'package:joys_calendar/repo/local/model/jieqi_model.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

class LocalDatasourceImpl extends LocalDatasource {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter<MemoModel>(MemoModelAdapter());
    Hive.registerAdapter<CalendarModel>(CalendarModelAdapter());
    Hive.registerAdapter<JieQiModel>(JieQiModelAdapter());
    await Hive.openBox<MemoModel>(MemoModel.boxKey);
    await Hive.openBox<CalendarModel>(CalendarModel.boxKey);
    await Hive.openBox<JieQiModel>(JieQiModel.boxKey);
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
  Future<void> deleteMemo(dynamic key) {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    return box.delete(key);
  }

  @override
  MemoModel getMemo(dynamic key) {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    return box.get(key)!;
  }

  @override
  List<MemoModel> getAllMemos() {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    var allMemos = box.values.toList();
    allMemos.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // sorted descending
    return allMemos;
  }

  @override
  Future<List<CalendarModel>> getCalendarModels(String countryCode) {
    // TODO: implement getCalendarModels
    throw UnimplementedError();
  }

  @override
  Future<List<JieQiModel>> getJieQiModels() {
    // TODO: implement getJieQiModels
    throw UnimplementedError();
  }

  @override
  Future<void> saveCalendarModels(List<CalendarModel> models) {
    // TODO: implement saveCalendarModels
    throw UnimplementedError();
  }

  @override
  Future<void> saveJieQiModels() {
    // TODO: implement saveJieQiModels
    throw UnimplementedError();
  }
}
