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

class SettingsItem {
  SettingType headerValue;
  bool isExpanded;

  SettingsItem(this.headerValue, this.isExpanded);
}
