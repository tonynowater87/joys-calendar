import 'package:joys_calendar/repo/local/model/calendar_model.dart';
import 'package:joys_calendar/repo/local/model/jieqi_model.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

abstract class LocalDatasource {
  Future<bool> hasMemo(DateTime dateTime);

  Future<int?> saveMemo(MemoModel memoModel);

  Future<void> deleteMemo(dynamic key);

  List<MemoModel> getFutureMemos();

  List<MemoModel> getMemos(DateTime dateTime);

  List<MemoModel> getAllMemos();

  MemoModel getMemo(dynamic key);

  List<CalendarModel> getFutureCalendarModels(String countryCode);

  List<CalendarModel> getCalendarModels(String countryCode);

  Future<void> saveCalendarModels(List<CalendarModel> models);

  List<JieQiModel> getFutureJieQiModels();

  List<JieQiModel> getJieQiModels();

  Future<void> saveJieQiModels(List<JieQiModel> models);

  String localMemoToJson();

  Future<void> replaceWithJson(String json);
}
