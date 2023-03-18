import 'package:equatable/equatable.dart';

import 'settings_item.dart';

class SettingsState extends Equatable {
  final List<SettingsEventItem> settingEventItems;

  const SettingsState.initial() : this._();

  SettingsState copyWith(List<SettingsEventItem> events) {
    return SettingsState(settingEventItems: events);
  }

  const SettingsState({
    required this.settingEventItems,
  });

  const SettingsState._({this.settingEventItems = const []});

  @override
  List<Object?> get props => [settingEventItems];
}
