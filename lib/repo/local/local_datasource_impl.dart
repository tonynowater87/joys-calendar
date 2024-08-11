import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/calendar_model.dart';
import 'package:joys_calendar/repo/local/model/jieqi_model.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

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
    var dateString = DateFormat(AppConstants.memoDateFormat).format(dateTime);
    // debugPrint('[Tony] getMemos: $dateString');
    return List<MemoModel>.generate(box.values.length, (index) {
      var memoModel = box.getAt(index)!;
      // convert old dateTime to new dateString
      if (memoModel.dateString.isEmpty) {
        memoModel.dateString =
            DateFormat(AppConstants.memoDateFormat).format(memoModel.dateTime);
      }
      return memoModel;
    })
        .where((element) => element.dateString == dateString)
        .whereType<MemoModel>()
        .toList();
  }

  @override
  Future<int?> saveMemo(MemoModel memoModel) async {
    final box = Hive.box<MemoModel>(MemoModel.boxKey);
    final existModel = Hive.box<MemoModel>(MemoModel.boxKey)
        .values
        .where((element) => element.key == memoModel.key);
    if (existModel.isEmpty) {
      return box.add(memoModel);
    } else {
      await box.put(memoModel.key, memoModel);
      return null;
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
    allMemos = allMemos.map((e) {
      // convert old dateTime to new dateString
      if (e.dateString.isEmpty) {
        e.dateString =
            DateFormat(AppConstants.memoDateFormat).format(e.dateTime);
      }
      return e;
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // sorted descending
    return allMemos;
  }

  @override
  List<CalendarModel> getCalendarModels(String countryCode) {
    final box = Hive.box<CalendarModel>(CalendarModel.boxKey);
    final allValues = box.values
        .where((element) =>
            element.country == countryCode &&
            // 過濾掉舊版key是2027-08-16 00:00:00.000, 新版key為`2027-08-16 00:00:00.000 zh-tw 中秋節`
            element.key.toString().length > 23)
        .toList();
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
  Future<List<EventModel>> saveCalendarModels(List<CalendarModel> models) {
    final box = Hive.box<CalendarModel>(CalendarModel.boxKey);
    List<EventModel> result = [];
    return Future.forEach(models, (element) async {

      await box.delete("${element.dateTime} ${element.country}"); // remove old key
      var key = "${element.dateTime} ${element.country} ${element.displayName}"; // save new key
      result.add(EventModel(
          date: element.dateTime,
          eventType: fromCreatorEmail(element.country)!,
          eventName: element.displayName,
          continuousDays: element.continuousDays));
      box.put(key, element);
    }).then((value) => result);
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
      // debugPrint('[Tony] recover memo=$memoModel');
    });

    // add to hive
    for (var element in downloadMemos) {
      await box.add(element);
    }
  }

  @override
  List<CalendarModel> getFutureCalendarModels(String countryCode) {
    var now = DateTime.now();
    var result = getCalendarModels(countryCode)
        .where((element) => element.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime)); // sorted ascending
    return result;
  }

  @override
  List<MemoModel> getFutureMemos() {
    var now = DateTime.now();
    var result = getAllMemos()
        .where((element) => element.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime)); // sorted ascending
    return result;
  }

  @override
  List<JieQiModel> getFutureJieQiModels() {
    var now = DateTime.now();
    var result = getJieQiModels()
        .where((element) => element.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime)); // sorted ascending
    return result;
  }
}
