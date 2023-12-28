import 'package:flutter/cupertino.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';
import 'package:joys_calendar/view/common/date_picker/date_picker_dialog.dart';
import 'package:lunar/lunar.dart';
import 'package:tuple/tuple.dart';

class LunarDatePicker extends StatefulWidget {
  late int _year;
  late int _month;
  late bool _isLeapMonth = false;
  int? _day;
  late Lunar _lunar;
  OnDateChanged? onDateChanged;

  LunarDatePicker({Key? key, this.onDateChanged}) : super(key: key) {
    var dateTimeNow = DateTime.now();
    _lunar = Solar.fromDate(dateTimeNow).getLunar();
    _year = _lunar.getYear();
    _month = _lunar.getMonth();
    _day = _lunar.getDay();
  }

  LunarDatePicker.fromDate(int year, int month, int? day,
      {Key? key, this.onDateChanged})
      : super(key: key) {
    _lunar = Lunar.fromYmd(year, month, day ?? 1);
    _year = _lunar.getYear();
    _month = _lunar.getMonth();
    if (day != null) {
      _day = _lunar.getDay();
    }
  }

  @override
  State<LunarDatePicker> createState() => _LunarDatePickerState();
}

class _LunarDatePickerState extends State<LunarDatePicker> {
  final List<Tuple2<int, String>> _years =
  List.generate(201, (index) => Tuple2(1900 + index, '年'));
  final ValueNotifier<List<Tuple2<int, String>>> _monthsNotifier = ValueNotifier([]);
  ValueNotifier<List<Tuple2<int, String>>> _daysNotifier = ValueNotifier([]);

  FixedExtentScrollController _yearController = FixedExtentScrollController();
  FixedExtentScrollController _monthController = FixedExtentScrollController();
  FixedExtentScrollController _dayController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    _updateMonths();
    _updateDays();
    widget._isLeapMonth = _isLeapMonth();

    _yearController = FixedExtentScrollController(
        initialItem: _years.map((e) => e.item1).toList().indexOf(widget._year));
    _monthController = FixedExtentScrollController(
        initialItem: _monthsNotifier.value
            .map((e) => e.item1)
            .toList()
            .indexOf(widget._month));

    if (widget._day != null) {
      _dayController = FixedExtentScrollController(
          initialItem: _daysNotifier.value
              .map((e) => e.item1)
              .toList()
              .indexOf(widget._day!));
    }
  }

  bool _isLeapMonth() =>
      _monthsNotifier.value[widget._month.abs() - 1].item2.contains('閏');

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
              widget._year = _years[index].item1;
              _updateMonths();
              _checkIfNeedUpdateMonthOrDayWhenYearChanged();
              widget.onDateChanged?.call(DateModel(
                  year: widget._year,
                  month: widget._month,
                  day: widget._day,
                  isLunar: true));
            },
            children: _years
                .map((e) => Center(child: Text('${e.item1}${e.item2}')))
                .toList(),
          ),
        ),
        Expanded(
          flex: 1,
          child: ValueListenableBuilder(
              valueListenable: _monthsNotifier,
              builder: (BuildContext context, List<Tuple2<int, String>> value,
                  Widget? child) {
                return CupertinoPicker(
                  scrollController: _monthController,
                  itemExtent: 50,
                  onSelectedItemChanged: (index) {
                    debugPrint(
                        '[Tony] onSelectedItemChanged _monthsNotifier.value[$index]: ${_monthsNotifier.value[index]}');
                    widget._month = value[index].item1;
                    widget._isLeapMonth = _isLeapMonth();
                    _updateDays();
                    _checkIfNeedUpdateDayWhenMonthChanged();
                    widget.onDateChanged?.call(DateModel(
                        year: widget._year,
                        month: widget._month,
                        day: widget._day,
                        isLunar: true));
                  },
                  children: value
                      .map((e) => Center(child: Text('${e.item2}')))
                      .toList(),
                );
              }),
        ),
        widget._day != null
            ? Expanded(
          flex: 1,
          child: ValueListenableBuilder(
            valueListenable: _daysNotifier,
            builder: (BuildContext context,
                List<Tuple2<int, String>> value, Widget? child) {
              return CupertinoPicker(
                scrollController: _dayController,
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  debugPrint(
                      '[Tony] onSelectedItemChanged _daysNotifier.value[$index]: ${_daysNotifier.value.length}');
                  widget._day = value[index].item1;
                  widget.onDateChanged?.call(DateModel(
                      year: widget._year,
                      month: widget._month,
                      day: widget._day!,
                      isLunar: true));
                },
                children: value
                    .map((e) => Center(child: Text('${e.item2}')))
                    .toList(),
              );
            },
          ),
        )
            : SizedBox(width: 0, height: 0),
      ],
    );
  }

  void _updateMonths() {
    LunarYear lunarYear = LunarYear(widget._year);
    _monthsNotifier.value = lunarYear.getMonthsInYear().map((LunarMonth e) {
      var month = e.getMonth();
      if (e.isLeap()) {
        return Tuple2<int, String>(month, '閏${LunarUtil.MONTH[month.abs()]}月');
      } else {
        return Tuple2<int, String>(month, '${LunarUtil.MONTH[month]}月');
      }
    }).toList();
  }

  void _updateDays() {
    LunarYear lunarYear = LunarYear(widget._lunar.getYear());
    LunarMonth lunarMonth = lunarYear.getMonth(widget._month)!;
    _daysNotifier.value = List.generate(
        lunarMonth.getDayCount(),
            (index) =>
            Tuple2<int, String>(index + 1, '${LunarUtil.DAY[index + 1]}日'));
  }

  void _checkIfNeedUpdateMonthOrDayWhenYearChanged() {
    LunarYear lunarYear = LunarYear(widget._year);
    LunarMonth lunarMonth = lunarYear.getMonth(widget._month.abs())!;
    if (widget._isLeapMonth && !lunarMonth.isLeap()) {
      debugPrint(
          '[Tony] _checkIfNeedUpdateMonthOrDayWhenYearChanged before ${widget._month} ${widget._isLeapMonth}');
      widget._month = lunarMonth.getMonth();
      widget._isLeapMonth = _isLeapMonth();
      debugPrint(
          '[Tony] _checkIfNeedUpdateMonthOrDayWhenYearChanged after ${widget._month} ${widget._isLeapMonth}');
      _monthController.animateToItem((widget._month - 1),
          duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      if (widget._day != null) {
        if (lunarMonth.getDayCount() < widget._day!) {
          widget._day = lunarMonth.getDayCount();
          _dayController.animateToItem((widget._day! - 1),
              duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
        }
      }
    }
  }

  void _checkIfNeedUpdateDayWhenMonthChanged() {
    LunarYear lunarYear = LunarYear(widget._lunar.getYear());
    LunarMonth lunarMonth = lunarYear.getMonth(widget._month)!;
    if (widget._day != null) {
      if (lunarMonth.getDayCount() < widget._day!) {
        widget._day = lunarMonth.getDayCount();
        _dayController.animateToItem((widget._day! - 1),
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    }
  }
}
