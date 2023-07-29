import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

enum SettingType { eventType, backup, locale }

extension SettingTypeExtensions on SettingType {
  String toLocalization() {
    switch (this) {
      case SettingType.eventType:
        return "選擇日曆要顯示的項目"; // TODO locale
      case SettingType.locale:
        return "其它"; // TODO locale
      case SettingType.backup:
        return "備份我的記事";
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
