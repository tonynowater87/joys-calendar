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

enum EventType { Taiwan, Japna, UK, US, Lunar }
