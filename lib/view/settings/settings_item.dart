import 'package:joys_calendar/repo/model/event_model.dart';

enum SettingType { eventType, locale }

extension SettingTypeExtensions on SettingType {
  String toLocalization() {
    switch (this) {
      case SettingType.eventType:
        return "設定要顯示的日曆事件"; // TODO locale
      case SettingType.locale:
        return "語系"; // TODO locale
    }
  }
}

class SettingsTitleItem {
  SettingType headerValue;
  bool isExpanded;

  SettingsTitleItem(this.headerValue, this.isExpanded);
}

class SettingsEventItem {
  EventType eventType;
  bool isSelected;

  SettingsEventItem(this.eventType, this.isSelected);
}
