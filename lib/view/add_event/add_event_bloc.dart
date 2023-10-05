import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/extentions/local_notification_provider_extensions.dart';
import 'package:joys_calendar/common/extentions/notify_id_extensions.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';

part 'add_event_event.dart';

part 'add_event_state.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  LocalDatasource localMemoRepository;
  SharedPreferenceProvider sharedPreferenceProvider;
  LocalNotificationProvider localNotificationProvider;

  dynamic? key;
  String updatedMemo = "";

  AddEventBloc(this.localMemoRepository, this.sharedPreferenceProvider,
      this.localNotificationProvider)
      : super(AddEventState.add()) {
    on<ChangeDateTimeEvent>((event, emit) {
      emit.call(state.copyWith(dateTime: event.memoDateTime));
    });

    on<UpdateMemoEvent>((event, emit) {
      updatedMemo = event.memo;
    });

    on<AddDateTimeEvent>((event, emit) {
      key = null;
      updatedMemo = "";
      emit.call(AddEventState.add());
    });

    on<EditDateTimeEvent>((event, emit) {
      final memoModel = localMemoRepository.getMemo(event.key);
      updatedMemo = memoModel.memo;
      key = memoModel.key;
      emit.call(AddEventState.edit(memoModel));
    });
  }

  Future<bool> saveEvent() async {
    if (updatedMemo.isEmpty) {
      return false;
    }
    var updatedMemoModel = state.memoModel..memo = updatedMemo;
    if (key != null) {
      // 編輯
      final memoModel = localMemoRepository.getMemo(key);
      await localMemoRepository.saveMemo(memoModel
        ..memo = updatedMemoModel.memo
        ..dateTime = updatedMemoModel.dateTime
        ..dateString = DateFormat(AppConstants.memoDateFormat)
            .format(updatedMemoModel.dateTime));
      await renewNotification(memoModel);

      return true;
    } else {
      // 新增
      var id = await localMemoRepository.saveMemo(updatedMemoModel);
      final memoModel = localMemoRepository.getMemo(id);
      await showNotification(memoModel);
      return true;
    }
  }

  Future<void> renewNotification(MemoModel memoModel) async {
    if (sharedPreferenceProvider.isMemoNotifyEnable() &&
        await localNotificationProvider.isPermissionGranted()) {
      int id = memoModel.getNotifyId();
      await localNotificationProvider.cancelNotification(id);
      localNotificationProvider.showMemoNotify(EventModel(
          date: memoModel.dateTime,
          eventType: EventType.custom,
          eventName: memoModel.memo,
          idForModify: memoModel.key));
    }
  }

  Future<void> showNotification(MemoModel memoModel) async {
    if (sharedPreferenceProvider.isMemoNotifyEnable() &&
        await localNotificationProvider.isPermissionGranted()) {
      localNotificationProvider.showMemoNotify(EventModel(
          date: memoModel.dateTime,
          eventType: EventType.custom,
          eventName: memoModel.memo,
          idForModify: memoModel.key));
    }
  }

  Future<void> cancelNotification(MemoModel memoModel) async {
    if (sharedPreferenceProvider.isMemoNotifyEnable()) {
      int id = memoModel.getNotifyId();
      await localNotificationProvider.cancelNotification(id);
    }
  }

  Future<void> delete() async {
    var memo = localMemoRepository.getMemo(key);
    await cancelNotification(memo);
    await localMemoRepository.deleteMemo(key);
  }
}
