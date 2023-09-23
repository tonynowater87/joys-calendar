part of 'settings_notify_cubit.dart';

@immutable
class SettingsNotifyState {
  final bool calendarNotify;
  final bool solarNotify;
  final bool memoNotify;

  const SettingsNotifyState(
      {required this.calendarNotify,
      required this.memoNotify,
      required this.solarNotify});
}
