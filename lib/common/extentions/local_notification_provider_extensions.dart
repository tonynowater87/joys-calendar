import 'dart:io';

import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/extentions/event_model_extensions.dart';
import 'package:joys_calendar/common/extentions/notify_id_extensions.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:timezone/timezone.dart' as tz;

extension LocalNotificationProviderExtension on LocalNotificationProvider {
  Future<void> showCalendarNotify(
      EventModel event, Map<dynamic, dynamic> continuousDayMap) async {
    var id = event.getNotifyId();
    var targetStartDateTime = tz.TZDateTime.from(event.date, tz.local);
    var startDateFormat =
        DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
            .format(event.date)
            .toString();
    if (event.continuousDays == 0) {
      showNotification(
          id, "明天 $startDateFormat", event.eventName, targetStartDateTime);
    } else {
      var key = event.getContinuousDayMapKey();
      if (event.continuousDays == continuousDayMap[key]) {
        continuousDayMap[key] = continuousDayMap[key]! - 1;
        var targetEndDateTime =
            event.date.add(Duration(days: event.continuousDays));
        var endDateFormat =
            DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
                .format(targetEndDateTime);
        showNotification(id, "明天 [${event.eventName}]",
            "開始連續假期 $startDateFormat - $endDateFormat", targetStartDateTime);
      }
    }
  }

  Future<void> showMemoNotify(EventModel event) async {
    int id = event.getNotifyId();
    var dateFormat =
        DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
            .format(event.date)
            .toString();
    var title = "明天 $dateFormat";
    showNotification(
        id, title, event.eventName, tz.TZDateTime.from(event.date, tz.local));
  }

  Future<void> showSolarNotify(EventModel event) async {
    int id = event.getNotifyId();
    var dateFormat =
        DateFormat(AppConstants.notifyDateFormat, Platform.localeName)
            .format(event.date)
            .toString();
    var title = "明天 $dateFormat";
    showNotification(
        id, title, event.eventName, tz.TZDateTime.from(event.date, tz.local));
  }
}
