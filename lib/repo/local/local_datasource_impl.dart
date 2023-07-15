import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    allMemos
        .sort((a, b) => b.dateTime.compareTo(a.dateTime)); // sorted descending
    return allMemos;
  }

  @override
  List<CalendarModel> getCalendarModels(String countryCode) {
    final box = Hive.box<CalendarModel>(CalendarModel.boxKey);
    final allValues =
        box.values.where((element) => element.country == countryCode).toList();
    allValues.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return allValues;
  }

  @override
  List<JieQiModel> getJieQiModels() {
    final box = Hive.box<JieQiModel>(JieQiModel.boxKey);
    final allValues = box.values.toList();
    allValues.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return allValues;
  }

  @override
  Future<void> saveCalendarModels(List<CalendarModel> models) {
    final box = Hive.box<CalendarModel>(CalendarModel.boxKey);
    return Future.forEach(
        models, (element) => box.put(element.dateTime.toString(), element));
  }

  @override
  Future<void> saveJieQiModels(List<JieQiModel> models) {
    final box = Hive.box<JieQiModel>(JieQiModel.boxKey);
    return Future.forEach(
        models, (element) => box.put(element.dateTime.toString(), element));
  }

  @override
  String localMemoToJson() {
    var box = Hive.box<MemoModel>(MemoModel.boxKey);
    Map<String, dynamic> map =
        box.toMap().map((key, value) => MapEntry(key.toString(), value));
    if (map.isEmpty) {
      return "";
    }
    String json = jsonEncode(map,
        toEncodable: (Object? value) => value is MemoModel
            ? MemoModel.toJson(value)
            : throw UnsupportedError('Cannot convert to JSON: $value'));
    return json;
  }

  @override
  Future<void> replaceWithJson(String json) async {
    // clear
    var box = Hive.box<MemoModel>(MemoModel.boxKey);
    final i = await box.clear();
    debugPrint('[Tony] clear done, $i');

    // convert to model
    Map<String, dynamic> jsonDecoded = jsonDecode(json);
    List<MemoModel> downloadMemos = [];
    jsonDecoded.forEach((key, value) {
      MemoModel memoModel = MemoModel.fromJson(value);
      downloadMemos.add(memoModel);
      debugPrint('[Tony] recover memo=$memoModel');
    });

    // add to hive
    for (var element in downloadMemos) {
      await box.add(element);
    }
  }
}
