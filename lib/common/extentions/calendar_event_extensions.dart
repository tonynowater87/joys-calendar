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
}
