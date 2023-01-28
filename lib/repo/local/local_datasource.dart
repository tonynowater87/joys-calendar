import 'package:joys_calendar/repo/local/model/calendar_model.dart';
import 'package:joys_calendar/repo/local/model/jieqi_model.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

abstract class LocalDatasource {
  Future<bool> hasMemo(DateTime dateTime);

  Future<void> saveMemo(MemoModel memoModel);

  Future<void> deleteMemo(dynamic key);

  List<MemoModel> getMemos(DateTime dateTime);

  List<MemoModel> getAllMemos();

  MemoModel getMemo(dynamic key);

  Future<List<CalendarModel>> getCalendarModels(String countryCode);
  Future<void> saveCalendarModels(List<CalendarModel> models);

  Future<List<JieQiModel>> getJieQiModels();
  Future<void> saveJieQiModels();
}
