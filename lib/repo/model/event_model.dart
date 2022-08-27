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
  lunar;
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
    }
  }
}
