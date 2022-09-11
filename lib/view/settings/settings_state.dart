import 'settings_item.dart';

enum SettingsStateStatus { initial, ready }

class SettingsState {
  final SettingsStateStatus status;
  final List<SettingsEventItem> settingEventItems;

  SettingsState.initial() : this._();

  SettingsState copyWith(List<SettingsEventItem> events, SettingsStateStatus status) {
    return SettingsState(settingEventItems: events, status: status);
  }

  const SettingsState({
    required this.status,
    required this.settingEventItems,
  });

  SettingsState._(
      {this.status = SettingsStateStatus.initial,
      this.settingEventItems = const []});
}
