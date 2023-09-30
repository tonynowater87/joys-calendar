import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/extentions/event_model_extensions.dart';
import 'package:joys_calendar/common/extentions/notify_id_extensions.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:timezone/timezone.dart' as tz;

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
          var targetStartDateTime = tz.TZDateTime.from(event.date, tz.local);
          var startDateFormat =
              DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
                  .format(event.date)
                  .toString();
          if (event.continuousDays == 0) {
            await localNotificationProvider.showNotification(id,
                "明天 $startDateFormat", event.eventName, targetStartDateTime);
          } else {
            var key = event.getContinuousDayMapKey();
            if (event.continuousDays == map[key]) {
              map[key] = map[key]! - 1;
              var targetEndDateTime =
                  event.date.add(Duration(days: event.continuousDays));
              var endDateFormat =
                  DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
                      .format(targetEndDateTime);
              await localNotificationProvider.showNotification(
                  id,
                  "明天 [${event.eventName}]",
                  "開始連續假期 $startDateFormat - $endDateFormat",
                  targetStartDateTime);
            }
          }
        } else {
          await localNotificationProvider.cancelNotification(id);
        }
      }
    }
  }

  Future<void> setSolarNotify(bool enable) async {
    var futureSolarEvents =
        await calendarEventRepository.getFutureSolarEvents();
    if (enable) {
      for (var event in futureSolarEvents) {
        int id = event.getNotifyId();
        var dateFormat =
            DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
                .format(event.date)
                .toString();
        var title = "明天 $dateFormat";
        localNotificationProvider.showNotification(id, title, event.eventName,
            tz.TZDateTime.from(event.date, tz.local));
      }
    } else {
      for (var event in futureSolarEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.cancelNotification(id);
      }
    }
  }

  Future<void> setMemoNotify(bool enable) async {
    var futureCustomEvents =
        await calendarEventRepository.getFutureCustomEvents();
    if (enable) {
      for (var event in futureCustomEvents) {
        int id = event.getNotifyId();
        var dateFormat =
            DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
                .format(event.date)
                .toString();
        var title = "明天 $dateFormat";
        localNotificationProvider.showNotification(id, title, event.eventName,
            tz.TZDateTime.from(event.date, tz.local));
      }
    } else {
      for (var event in futureCustomEvents) {
        int id = event.getNotifyId();
        localNotificationProvider.cancelNotification(id);
      }
    }
  }
}
