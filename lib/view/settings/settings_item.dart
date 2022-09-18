import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

enum SettingType { eventType, locale }

extension SettingTypeExtensions on SettingType {
  String toLocalization() {
    switch (this) {
      case SettingType.eventType:
        return "選擇要顯示的項目(國家節日、農曆、節氣)"; // TODO locale
      case SettingType.locale:
        return "其它"; // TODO locale
    }
  }
}

class SettingsTitleItem {
  SettingType headerValue;
  bool isExpanded;

  SettingsTitleItem(this.headerValue, this.isExpanded);
}

class SettingsEventItem extends Equatable {
  EventType eventType;
  bool isSelected;

  SettingsEventItem(this.eventType, this.isSelected);

  @override
  List<Object?> get props => [eventType, isSelected];
}
