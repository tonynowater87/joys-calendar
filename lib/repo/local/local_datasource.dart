import 'package:joys_calendar/repo/local/model/memo_model.dart';

abstract class LocalDatasource {
  Future<bool> hasMemo(DateTime dateTime);

  Future<void> saveMemo(MemoModel memoModel);

  Future<void> deleteMemo(MemoModel memoModel);

  Future<List<MemoModel>> getMemos(DateTime dateTime);

  Future<MemoModel> getMemo(dynamic key);
}
