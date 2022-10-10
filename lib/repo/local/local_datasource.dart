import 'package:joys_calendar/repo/local/model/memo_model.dart';

abstract class LocalDatasource {
  Future<bool> hasMemo(DateTime dateTime);

  Future<void> saveMemo(MemoModel memoModel);

  Future<void> deleteMemo(dynamic key);

  List<MemoModel> getMemos(DateTime dateTime);

  List<MemoModel> getAllMemos();

  MemoModel getMemo(dynamic key);
}
