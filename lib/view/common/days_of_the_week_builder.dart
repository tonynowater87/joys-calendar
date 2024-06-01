import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';

DaysBuilder daysOfTheWeekBuilder = (dayIndex) {
  final labels = ["日", "一", "二", "三", "四", "五", "六"];
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Text(
      labels[dayIndex],
      textAlign: TextAlign.center,
    ),
  );
};