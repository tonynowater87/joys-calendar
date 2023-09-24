part of 'settings_notify_cubit.dart';

@immutable
class SettingsNotifyState implements Equatable {
  final bool calendarNotify;
  final bool solarNotify;
  final bool memoNotify;
  final bool showNotifyAlertPermissionDialog;

  const SettingsNotifyState(
      {required this.calendarNotify,
      required this.memoNotify,
      required this.solarNotify,
      required this.showNotifyAlertPermissionDialog});

  SettingsNotifyState copyWith({
    bool? calendarNotify,
    bool? solarNotify,
    bool? memoNotify,
    bool? showNotifyAlertPermissionDialog,
  }) {
    return SettingsNotifyState(
      calendarNotify: calendarNotify ?? this.calendarNotify,
      solarNotify: solarNotify ?? this.solarNotify,
      memoNotify: memoNotify ?? this.memoNotify,
      showNotifyAlertPermissionDialog: showNotifyAlertPermissionDialog ??
          this.showNotifyAlertPermissionDialog,
    );
  }

  @override
  String toString() {
    return 'SettingsNotifyState{calendarNotify: $calendarNotify, solarNotify: $solarNotify, memoNotify: $memoNotify, showNotifyAlertPermissionDialog: $showNotifyAlertPermissionDialog}';
  }

  @override
  List<Object?> get props => [
        calendarNotify,
        solarNotify,
        memoNotify,
        showNotifyAlertPermissionDialog,
      ];

  @override
  bool? get stringify => true;
}
