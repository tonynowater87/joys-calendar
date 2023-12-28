import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';
import 'package:joys_calendar/view/common/date_picker/date_picker_dialog.dart';
import 'package:joys_calendar/view/common/date_picker/gregorian_date_picker.dart';
import 'package:joys_calendar/view/common/date_picker/lunar_date_picker.dart';
import 'package:lunar/calendar/Lunar.dart';

class DefaultDatePickerDialog extends StatefulWidget {
  late int _year;
  late int _month;
  int? _day;
  bool _isLunar = false;
  OnDateChanged? onDateChanged;

  DefaultDatePickerDialog({Key? key, this.onDateChanged}) : super(key: key) {
    var dateTimeNow = DateTime.now();
    _isLunar = false;
    _year = dateTimeNow.year;
    _month = dateTimeNow.month;
    _day = dateTimeNow.day;
  }

  DefaultDatePickerDialog.fromDate(int year, int month, int? day,
      {Key? key, this.onDateChanged})
      : super(key: key) {
    _isLunar = false;
    _year = year;
    _month = month;
    if (day != null) {
      _day = day;
    }
  }

  DefaultDatePickerDialog.fromLunarDate(int year, int month, int? day,
      {Key? key, this.onDateChanged})
      : super(key: key) {
    _isLunar = true;
    _year = year;
    _month = month;
    if (day != null) {
      _day = day;
    }
  }

  @override
  State<DefaultDatePickerDialog> createState() =>
      _DefaultDatePickerDialogState();
}

class _DefaultDatePickerDialogState extends State<DefaultDatePickerDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('選擇日期', style: Theme.of(context).textTheme.titleLarge),
          ),
          SizedBox(
            width: double.infinity,
            child: CupertinoSegmentedControl(
                selectedColor: Theme.of(context).colorScheme.primary,
                unselectedColor: Theme.of(context).colorScheme.surface,
                groupValue: widget._isLunar ? 2 : 1,
                children: const <int, Text>{
                  1: Text('國曆'),
                  2: Text('農曆'),
                },
                onValueChanged: (value) {
                  setState(() {
                    if (!widget._isLunar && value == 2) {
                      debugPrint(
                          '[Tony] 轉農曆前 ${widget._year} ${widget._month} ${widget._day}');
                      var luanr = Lunar.fromDate(
                          DateTime(widget._year, widget._month, widget._day ?? 1));
                      widget._year = luanr.getYear();
                      widget._month = luanr.getMonth();
                      widget._day = widget._day == null ? null : luanr.getDay();
                      debugPrint(
                          '[Tony] 轉農曆後 ${widget._year} ${widget._month} ${widget._day}');
                    } else {
                      debugPrint(
                          '[Tony] 轉國曆前 ${widget._year} ${widget._month} ${widget._day}');
                      var solar = Lunar.fromYmd(
                              widget._year, widget._month, widget._day ?? 1)
                          .getSolar();
                      widget._year = solar.getYear();
                      widget._month = solar.getMonth();
                      widget._day = widget._day == null ? null : solar.getDay();
                      debugPrint(
                          '[Tony] 轉國曆後 ${widget._year} ${widget._month} ${widget._day}');
                    }
                    widget._isLunar = value == 2;
                  });
                }),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.25),
                child: widget._isLunar
                    ? LunarDatePicker.fromDate(
                        widget._year, widget._month, widget._day,
                        onDateChanged: (date) {
                        widget._year = date.year;
                        widget._month = date.month;
                        widget._day = date.day;
                        widget.onDateChanged?.call(date);
                      })
                    : GregorianDatePicker.fromDate(
                        widget._year, widget._month, widget._day,
                        onDateChanged: (date) {
                        widget._year = date.year;
                        widget._month = date.month;
                        widget._day = date.day;
                        widget.onDateChanged?.call(date);
                      })),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CupertinoButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
              Expanded(
                flex: 1,
                child: CupertinoButton(
                    child: Text('確定'),
                    onPressed: () {
                      Navigator.of(context).pop(DateModel(
                          year: widget._year,
                          month: widget._month,
                          day: widget._day ?? 1,
                          isLunar: widget._isLunar));
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }
}
