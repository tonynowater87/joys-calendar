import 'package:flutter/foundation.dart';
import 'package:joys_calendar/common/extentions/event_model_extensions.dart';
import 'package:joys_calendar/common/extentions/local_notification_provider_extensions.dart';
import 'package:joys_calendar/common/extentions/notify_id_extensions.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

class NotificationHelper {
  late CalendarEventRepository calendarEventRepository;
  late LocalNotificationProvider localNotificationProvider;

  NotificationHelper(
      {required this.calendarEventRepository,
      required this.localNotificationProvider});

  Future<void> setCalendarNotify(List<EventType> countries, bool enable) async {
    for (var country in countries) {
      var countryEvents = await calendarEventRepository
          .getFutureEventsFromLocalDB(country.toCountryCode());

      var map = countryEvents.fold({}, (map, element) {
        var key = element.getContinuousDayMapKey();
        map[key] = map[key] == null ? 0 : map[key]! + 1;
        return map;
      });

      for (var event in countryEvents) {
        debugPrint('[Test] event: ${event.eventName}, ${event.date}');
        int id = event.getNotifyId();
        if (enable) {
          await localNotificationProvider.showCalendarNotify(event, map);
        } else {
          await localNotificationProvider.cancelNotification(id);
        }
      }
    }
  }

  Future<void> setSolarNotify(bool enable) async {
    var futureSolarEvents =
        await calendarEventRepository.getFutureSolarEvents();
    for (var event in futureSolarEvents) {
      int id = event.getNotifyId();
      if (enable) {
        localNotificationProvider.showSolarNotify(event);
      } else {
        localNotificationProvider.cancelNotification(id);
      }
    }
  }

  Future<void> setMemoNotify(bool enable) async {
    var futureCustomEvents =
        await calendarEventRepository.getFutureCustomEvents();
    for (var event in futureCustomEvents) {
      int id = event.getNotifyId();

      if (enable) {
        localNotificationProvider.showMemoNotify(event);
      } else {
        localNotificationProvider.cancelNotification(id);
      }
    }
  }
}
