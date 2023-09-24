import 'package:joys_calendar/repo/model/event_model.dart';

extension EventModelExtensions on EventModel {
  int getNotifyId() {
    if (eventType == EventType.solar) {
      return (date.millisecondsSinceEpoch & 0xFFFFFFFF >>> 2) +
          EventType.solar.index;
    }

    if (eventType == EventType.custom) {
      return (date.millisecondsSinceEpoch & 0xFFFFFFFF >>> 4) +
          (int.tryParse(idForModify.toString()) ?? 0);
    }

    return (date.millisecondsSinceEpoch & 0xFFFFFFFF >>> 5) + eventType.index;
  }
}
