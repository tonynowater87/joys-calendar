import 'package:equatable/equatable.dart';

import 'settings_item.dart';

enum SettingsStateStatus { initial, ready, add, remove }

class SettingsState extends Equatable {
  final SettingsStateStatus status;
  final List<SettingsEventItem> settingEventItems;

  SettingsState.initial() : this._();

  SettingsState copyWith(List<SettingsEventItem> events, SettingsStateStatus status) {
    return SettingsState(settingEventItems: events.toList(), status: status);
  }

  const SettingsState({
    required this.status,
    required this.settingEventItems,
  });

  SettingsState._(
      {this.status = SettingsStateStatus.initial,
      this.settingEventItems = const []});

  @override
  List<Object?> get props => [status, settingEventItems];
}
