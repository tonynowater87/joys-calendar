import 'dart:ui';

import 'package:joys_calendar/common/configs/colors.dart';

class EventModel {
  late DateTime date;
  late EventType eventType;
  late String eventName;

  EventModel({
    required this.date,
    required this.eventType,
    required this.eventName,
  });
}

enum EventType { taiwan, china, hongKong, japan, uk, usa, lunar, solar, custom }

EventType? fromCreatorEmail(String? email) {
  if (email == null) return null;
  for (var eventType in EventType.values) {
    if (email.contains(eventType.toCountryCode())) {
      return eventType;
    }
  }
  return null;
}

extension EventTypeExtensions on EventType {
  EventType fromCountryCode(String countryCode) {
    switch (countryCode) {
      case "zh-tw.taiwan":
        return EventType.taiwan;
      case "zh-tw.china":
        return EventType.china;
      case "zh-tw.hong_kong":
        return EventType.hongKong;
      case "ja.japanese":
        return EventType.japan;
      case "en.uk":
        return EventType.uk;
      case "en.usa":
        return EventType.usa;
      default:
        throw Exception("illegal countryCode = $countryCode");
    }
  }

  String toCountryCode() {
    switch (this) {
      case EventType.taiwan:
        return "zh-tw.taiwan";
      case EventType.china:
        return "zh-tw.china";
      case EventType.hongKong:
        return "zh-tw.hong_kong";
      case EventType.japan:
        return "ja.japanese";
      case EventType.uk:
        return "en.uk";
      case EventType.usa:
        return "en.usa";
      case EventType.lunar:
        throw Exception("illegal eventType = $this");
      case EventType.solar:
        throw Exception("illegal eventType = $this");
      case EventType.custom:
        throw Exception("illegal eventType = $this");
    }
  }

  String toSettingName() {
    switch (this) {
      case EventType.taiwan:
        return "台灣節日";
      case EventType.china:
        return "中國節日";
      case EventType.hongKong:
        return "香港節日";
      case EventType.japan:
        return "日本節日";
      case EventType.uk:
        return "英國節日";
      case EventType.usa:
        return "美國節日";
      case EventType.lunar:
        return "農曆日期";
      case EventType.solar:
        return "２４節氣";
      case EventType.custom:
        return "我的記事";
    }
  }

  Color toEventColor() {
    switch (this) {
      case EventType.taiwan:
        return AppColors.blue;
      case EventType.china:
        return AppColors.nord11;
      case EventType.hongKong:
        return AppColors.yellow;
      case EventType.japan:
        return AppColors.nord14;
      case EventType.uk:
        return AppColors.nord7;
      case EventType.usa:
        return AppColors.nord10;
      case EventType.lunar:
        return AppColors.nord13.withRed(104);
      case EventType.solar:
        return AppColors.nord13.withRed(104);
      case EventType.custom:
        return AppColors.lightBlue;
    }
  }
}
