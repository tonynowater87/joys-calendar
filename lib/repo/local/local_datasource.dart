import 'package:joys_calendar/repo/local/model/memo_model.dart';

abstract class LocalDatasource {
  Future<bool> hasMemo(DateTime dateTime);

  Future<void> saveMemo(DateTime dateTime, String memo);

  Future<List<MemoModel>> getMemos(DateTime dateTime);
}
