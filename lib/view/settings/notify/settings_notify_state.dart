part of 'settings_notify_cubit.dart';

@immutable
class SettingsNotifyState implements Equatable {
  final bool calendarNotify;
  final bool solarNotify;
  final bool memoNotify;
  final bool showNotifyAlertPermissionDialog;
  final bool isLoading;
  final TimeOfDay notifyTime;

  const SettingsNotifyState(
      {required this.calendarNotify,
      required this.memoNotify,
      required this.solarNotify,
      required this.showNotifyAlertPermissionDialog,
      required this.isLoading,
      required this.notifyTime});

  SettingsNotifyState copyWith({
    bool? calendarNotify,
    bool? solarNotify,
    bool? memoNotify,
    bool? isLoading,
    bool? showNotifyAlertPermissionDialog,
    TimeOfDay? notifyTime,
  }) {
    return SettingsNotifyState(
      calendarNotify: calendarNotify ?? this.calendarNotify,
      solarNotify: solarNotify ?? this.solarNotify,
      memoNotify: memoNotify ?? this.memoNotify,
      isLoading: isLoading ?? this.isLoading,
      showNotifyAlertPermissionDialog: showNotifyAlertPermissionDialog ??
          this.showNotifyAlertPermissionDialog,
      notifyTime: notifyTime ?? this.notifyTime,
    );
  }

  @override
  String toString() {
    return 'SettingsNotifyState{calendarNotify: $calendarNotify, solarNotify: $solarNotify, memoNotify: $memoNotify, isLoading: $isLoading ,showNotifyAlertPermissionDialog: $showNotifyAlertPermissionDialog, notifyTime: $notifyTime}';
  }

  @override
  List<Object?> get props => [
        calendarNotify,
        solarNotify,
        memoNotify,
        showNotifyAlertPermissionDialog,
        notifyTime
      ];

  @override
  bool? get stringify => true;
}
