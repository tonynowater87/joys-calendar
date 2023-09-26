import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../settings_item.dart';

@immutable
class SettingsState extends Equatable {
  final List<SettingsEventItem> settingEventItems;
  bool isLoaded = false;

  SettingsState({
    required this.settingEventItems,
    required this.isLoaded,
  });

  copyWith({
    List<SettingsEventItem>? settingEventItems,
    bool? isLoaded,
  }) {
    return SettingsState(
      settingEventItems: settingEventItems ?? this.settingEventItems,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [settingEventItems, isLoaded];
}
