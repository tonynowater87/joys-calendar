import 'dart:ui';

import 'package:joys_calendar/common/themes/nord_color.dart';

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

enum EventType {
  taiwan,
  japan,
  uk,
  usa,
  lunar,
  solar,
}

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
    }
  }

  Color toEventColor() {
    switch (this) {
      case EventType.taiwan:
        return nord11;
      case EventType.japan:
        return nord14;
      case EventType.uk:
        return nord7;
      case EventType.usa:
        return nord10;
      case EventType.lunar:
        return nord13.withRed(104);
      case EventType.solar:
        return nord13.withRed(104);
    }
  }
}
