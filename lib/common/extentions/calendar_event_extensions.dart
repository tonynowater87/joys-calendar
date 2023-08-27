import 'package:cell_calendar/cell_calendar.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

extension CalendarEventExtensions on CalendarEvent {
  String extractEventTypeName() {
    final _eventID = eventID ?? "";
    if (_eventID.isEmpty) {
      return "";
    }
    return _eventID.split(",")[0];
  }

  String extractEventIdForModify() {
    final _eventID = eventID ?? "";
    if (_eventID.isEmpty) {
      return "";
    }
    return _eventID.split(",")[1];
  }

  bool isGoogleCalendarEvent() {
    if (extractEventTypeName() == EventType.taiwan.name) {
      return true;
    } else if (extractEventTypeName() == EventType.china.name) {
      return true;
    } else if (extractEventTypeName() == EventType.hongKong.name) {
      return true;
    } else if (extractEventTypeName() == EventType.japan.name) {
      return true;
    } else if (extractEventTypeName() == EventType.uk.name) {
      return true;
    } else if (extractEventTypeName() == EventType.usa.name) {
      return true;
    } else {
      return false;
    }
  }

  EventType getEventType() {
    if (extractEventTypeName() == EventType.taiwan.name) {
      return EventType.taiwan;
    } else if (extractEventTypeName() == EventType.china.name) {
      return EventType.china;
    } else if (extractEventTypeName() == EventType.hongKong.name) {
      return EventType.hongKong;
    } else if (extractEventTypeName() == EventType.japan.name) {
      return EventType.japan;
    } else if (extractEventTypeName() == EventType.uk.name) {
      return EventType.uk;
    } else if (extractEventTypeName() == EventType.usa.name) {
      return EventType.usa;
    } else if (extractEventTypeName() == EventType.lunar.name) {
      return EventType.lunar;
    } else if (extractEventTypeName() == EventType.solar.name) {
      return EventType.solar;
    } else if (extractEventTypeName() == EventType.custom.name) {
      return EventType.custom;
    } else {
      throw Exception("illegal eventID = $extractEventTypeName");
    }
  }
}
