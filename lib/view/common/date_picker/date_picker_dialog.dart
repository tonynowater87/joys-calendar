import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';
import 'package:joys_calendar/view/common/date_picker/gregorian_date_picker.dart';
import 'package:joys_calendar/view/common/date_picker/lunar_date_picker.dart';
import 'package:lunar/calendar/Solar.dart';

typedef OnDateChanged = void Function(DateModel dateModel);

class GregorianLunarPickerWidget extends StatefulWidget {
  bool _isLunar = false;
  late int _year;
  late int _month;
  late int _day;

  OnDateChanged? onDateChanged;

  GregorianLunarPickerWidget({Key? key, this.onDateChanged}) : super(key: key) {
    var dateTimeNow = DateTime.now();
    _year = dateTimeNow.year;
    _month = dateTimeNow.month;
    _day = dateTimeNow.day;
  }

  GregorianLunarPickerWidget.fromDate(DateTime date,
      {Key? key, this.onDateChanged})
      : super(key: key) {
    _year = date.year;
    _month = date.month;
    _day = date.day;
  }

  GregorianLunarPickerWidget.fromLunarDate(Solar date,
      {Key? key, this.onDateChanged})
      : super(key: key) {
    _year = date.getYear();
    _month = date.getMonth();
    _day = date.getDay();
    _isLunar = true;
  }

  @override
  State<GregorianLunarPickerWidget> createState() =>
      _GregorianLunarPickerWidgetState();
}

class _GregorianLunarPickerWidgetState
    extends State<GregorianLunarPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget._isLunar
          ? GregorianDatePicker.fromDate(
              widget._year, widget._month, widget._day, onDateChanged: (date) {
              widget.onDateChanged?.call(date);
            })
          : LunarDatePicker.fromDate(widget._year, widget._month, widget._day,
              onDateChanged: (date) {
              widget.onDateChanged?.call(date);
            })
    ]);
  }
}
