import 'package:cell_calendar/cell_calendar.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

extension CalendarEventExtensions on CalendarEvent {
  bool isGoogleCalendarEvent() {
    if (eventID == EventType.taiwan.name) {
      return true;
    } else if (eventID == EventType.china.name) {
      return true;
    } else if (eventID == EventType.hongKong.name) {
      return true;
    } else if (eventID == EventType.japan.name) {
      return true;
    } else if (eventID == EventType.uk.name) {
      return true;
    } else if (eventID == EventType.usa.name) {
      return true;
    } else {
      return false;
    }
  }

  EventType getEventType() {
    if (eventID == EventType.taiwan.name) {
      return EventType.taiwan;
    } else if (eventID == EventType.china.name) {
      return EventType.china;
    } else if (eventID == EventType.hongKong.name) {
      return EventType.hongKong;
    } else if (eventID == EventType.japan.name) {
      return EventType.japan;
    } else if (eventID == EventType.uk.name) {
      return EventType.uk;
    } else if (eventID == EventType.usa.name) {
      return EventType.usa;
    } else if (eventID == EventType.lunar.name) {
      return EventType.lunar;
    } else if (eventID == EventType.solar.name) {
      return EventType.solar;
    } else if (eventID == EventType.custom.name) {
      return EventType.custom;
    } else {
      throw Exception("illegal eventID = $eventID");
    }
  }
}
