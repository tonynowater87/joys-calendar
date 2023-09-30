import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

extension EventModelExtensions on EventModel {
  String getContinuousDayMapKey() {
    String key;
    if (eventName.contains(AppConstants.LUNAR_CHINESE_YEAR) &&
        !eventName.contains(AppConstants.FOR_LUNAR_CHINESE_YEAR_WORK_DAY)) {
      key = date.year.toString() + AppConstants.LUNAR_CHINESE_YEAR;
    } else if (eventName
        .contains(AppConstants.FOR_LUNAR_CHINESE_YEAR_WORK_DAY)) {
      key = date.year.toString() +
          eventName +
          date.millisecondsSinceEpoch.toString();
    } else {
      key = date.year.toString() + eventName;
    }

    return key;
  }
}
