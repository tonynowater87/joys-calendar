import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';
import 'package:joys_calendar/view/common/date_picker/date_picker_dialog.dart';

class GregorianDatePicker extends StatefulWidget {
  late int _year;
  late int _month;
  int? _day;

  OnDateChanged? onDateChanged;

  GregorianDatePicker({Key? key, this.onDateChanged}) : super(key: key) {
    var dateTimeNow = DateTime.now();
    _year = dateTimeNow.year;
    _month = dateTimeNow.month;
    _day = dateTimeNow.day;
  }

  GregorianDatePicker.fromDate(int year, int month, int? day, {Key? key, this.onDateChanged})
      : super(key: key) {
    _year = year;
    _month = month;
    if (day != null) {
      _day = day;
    }
  }

  @override
  State<GregorianDatePicker> createState() => _GregorianDatePickerState();
}

class _GregorianDatePickerState extends State<GregorianDatePicker> {
  ValueNotifier<List<int>> _daysNotifier = ValueNotifier([]);

  final List<int> _years = List.generate(DateTime.now().year + 100, (index) => index + 1);
  final List<int> _months = List.generate(12, (index) => index + 1);

  FixedExtentScrollController _yearController = FixedExtentScrollController();
  FixedExtentScrollController _monthController = FixedExtentScrollController();
  FixedExtentScrollController _dayController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    _updateDays();
    _yearController =
        FixedExtentScrollController(initialItem: _years.indexOf(widget._year));
    _monthController = FixedExtentScrollController(
        initialItem: _months.indexOf(widget._month));

    if (widget._day != null) {
      _dayController = FixedExtentScrollController(
          initialItem: _daysNotifier.value.indexOf(widget._day!));
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: CupertinoPicker(
            scrollController: _yearController,
            itemExtent: 50,
            onSelectedItemChanged: (index) {
              debugPrint(
                  '[Tony] onSelectedItemChanged _years[$index]: ${_years[index]}');
              widget._year = _years[index];
              _updateDays();
              _checkIfNeedUpdateDayWhenYearChanged();
              widget.onDateChanged?.call(DateModel(
                  year: widget._year,
                  month: widget._month,
                  day: widget._day));
            },
            children: _years.map((e) => Center(child: Text('$e年'))).toList(),
          ),
        ),
        Expanded(
          flex: 1,
          child: CupertinoPicker(
            scrollController: _monthController,
            itemExtent: 50,
            onSelectedItemChanged: (index) {
              debugPrint(
                  '[Tony] onSelectedItemChanged _months.value[$index]: ${_months.length}');
              widget._month = _months[index];
              _updateDays();
              _checkIfNeedUpdateDayWhenMonthChanged();
              widget.onDateChanged?.call(DateModel(
                  year: widget._year,
                  month: widget._month,
                  day: widget._day));
            },
            children: _months.map((e) => Center(child: Text('$e月'))).toList(),
          ),
        ),
        widget._day != null ? Expanded(
          flex: 1,
          child: ValueListenableBuilder(
            valueListenable: _daysNotifier,
            builder: (BuildContext context, List<int> value, Widget? child) {
              return CupertinoPicker(
                scrollController: _dayController,
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  debugPrint(
                      '[Tony] onSelectedItemChanged _daysNotifier.value[$index]: ${_daysNotifier.value.length}');
                  widget._day = value[index];
                  widget.onDateChanged?.call(DateModel(
                      year: widget._year,
                      month: widget._month,
                      day: widget._day!));
                },
                children: value.map((e) => Center(child: Text('$e日'))).toList(),
              );
            },
          ),
        )
            : SizedBox(
          height: 0,
          width: 0,
        ),
      ],
    );
  }

  void _updateDays() {
    List<int> daysInMonths = [];
    var daysInMonth = DateUtils.getDaysInMonth(widget._year, widget._month);
    for (var i = 1; i <= daysInMonth; i++) {
      daysInMonths.add(i);
    }
    _daysNotifier.value = daysInMonths;
  }

  void _checkIfNeedUpdateDayWhenYearChanged() {
    if (widget._day == null) {
      return;
    }
    if (widget._month == 2) {
      if (!_isLeapYear(widget._year)) {
        if (widget._day == 29) {
          widget._day = 28;
        }
      }
    }
  }

  void _checkIfNeedUpdateDayWhenMonthChanged() {
    if (widget._day == null) {
      return;
    }
    int daysInMonth = DateUtils.getDaysInMonth(widget._year, widget._month);
    debugPrint(
        '[Tony] _checkIfNeedUpdateDayWhenMonthChanged, daysInMonth: $daysInMonth, _day: ${widget._day}');
    if (widget._day! > daysInMonth) {
      widget._day = daysInMonth;
      _dayController.animateToItem((widget._day! - 1),
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    }
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  }
}