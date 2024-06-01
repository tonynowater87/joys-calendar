import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/extentions/date_time_extensions.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/common/utils/class_utils.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';
import 'package:joys_calendar/view/common/date_picker/default_date_picker_dialog.dart';
import 'package:joys_calendar/view/common/days_of_the_week_builder.dart';
import 'package:joys_calendar/view/common/number_picker.dart';
import 'package:joys_calendar/view/date_calculator/date_calculator_cubit.dart';

class DateCalculatorPage extends StatefulWidget {
  const DateCalculatorPage({super.key});

  @override
  State<DateCalculatorPage> createState() => _DateCalculatorPageState();
}

class _DateCalculatorPageState extends State<DateCalculatorPage> {
  final CellCalendarPageController _cellCalendarPageController =
      CellCalendarPageController();

  late final CalendarEventRepository _calendarEventRepository;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? currentDate;

  @override
  void initState() {
    super.initState();
    // TODO show lunar date
    _calendarEventRepository = context.read<CalendarEventRepository>();
  }

  @override
  Widget build(BuildContext context) {
    DateCalculatorState state = context.watch<DateCalculatorCubit>().state;

    return BlocListener<DateCalculatorCubit, DateCalculatorState>(
      listener: (context, state) {
        _startDate = state.startDateDateTime;
        currentDate = _startDate;
        _cellCalendarPageController.animateToDate(currentDate!,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

        if (state is DateCalculatorAddition) {
          _endDate = ClassUtils.tryCast<DateCalculatorAddition>(state)
              ?.endDateDateTime;
        } else if (state is DateCalculatorSubtraction) {
          _endDate = ClassUtils.tryCast<DateCalculatorAddition>(state)
              ?.endDateDateTime;
        } else if (state is DateCalculatorInterval) {
          var endDate = ClassUtils.tryCast<DateCalculatorInterval>(state)
              ?.endDate
              ?.toSolar();
          if (endDate != null) {
            _endDate = DateTime(
                endDate.getYear(), endDate.getMonth(), endDate.getDay());
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('日期計算器'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Visibility(
                visible: true,
                child: Expanded(
                  child: Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: true,
                        child: CellCalendar(
                            cellCalendarPageController:
                                _cellCalendarPageController,
                            todayMarkColor: Colors.transparent,
                            todayTextColor: Colors.black,
                            events: state.calcDaysEvents,
                            daysOfTheWeekBuilder: daysOfTheWeekBuilder,
                            monthYearLabelBuilder: (datetime) {
                              final yearString = DateFormat(
                                      '西元 y年', AppConstants.defaultLocale)
                                  .format(datetime!);
                              final monthString =
                                  DateFormat('MMMM', AppConstants.defaultLocale)
                                      .format(datetime);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                              "$yearString ${datetime.yearOfRoc}"),
                                          Text(
                                              "$monthString ${datetime.ganZhi} ${datetime.shenXiao}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: InkWell(
                                onTap: () {
                                  if (currentDate?.isSameMonth(_startDate) ==
                                      true) {
                                    return;
                                  }
                                  setState(() {
                                    currentDate = _startDate;
                                  });
                                  _cellCalendarPageController.animateToDate(
                                      currentDate!,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                },
                                child: Opacity(
                                  opacity:
                                      currentDate?.isSameMonth(_startDate) ==
                                              true
                                          ? 0.3
                                          : 1.0,
                                  child: const Icon(Icons
                                      .keyboard_double_arrow_left_outlined),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: InkWell(
                                onTap: () {
                                  if (currentDate?.isSameMonth(_startDate) ==
                                      true) {
                                    return;
                                  }

                                  setState(() {
                                    currentDate = currentDate!
                                        .subtract(const Duration(days: 30));
                                  });

                                  _cellCalendarPageController.animateToDate(
                                      currentDate!,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                },
                                child: Opacity(
                                    opacity:
                                        currentDate?.isSameMonth(_startDate) ==
                                                true
                                            ? 0.3
                                            : 1.0,
                                    child: const Icon(Icons.navigate_before))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: InkWell(
                                onTap: () {
                                  if (currentDate?.isSameMonth(_endDate) ==
                                      true) {
                                    return;
                                  }
                                  setState(() {
                                    currentDate = currentDate!
                                        .add(const Duration(days: 30));
                                  });
                                  _cellCalendarPageController.animateToDate(
                                      currentDate!,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                },
                                child: Opacity(
                                    opacity:
                                        currentDate?.isSameMonth(_endDate) ==
                                                true
                                            ? 0.3
                                            : 1.0,
                                    child: const Icon(Icons.navigate_next))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: InkWell(
                                onTap: () {
                                  if (currentDate?.isSameMonth(_endDate) ==
                                      true) {
                                    return;
                                  }
                                  setState(() {
                                    currentDate = _endDate;
                                  });
                                  _cellCalendarPageController.animateToDate(
                                      currentDate!,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                },
                                child: Opacity(
                                  opacity:
                                      currentDate?.isSameMonth(_endDate) == true
                                          ? 0.3
                                          : 1.0,
                                  child: const Icon(Icons
                                      .keyboard_double_arrow_right_outlined),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      switch (state.runtimeType) {
                        case DateCalculatorInterval:
                          showDialog(
                              context: context,
                              builder: (context) => AddEventPage());
                          break;
                        case DateCalculatorAddition:
                          showDialog(
                              context: context,
                              builder: (context) => AddEventPage(
                                  dateTime: ClassUtils.tryCast<
                                          DateCalculatorAddition>(state)!
                                      .endDateDateTime));
                          break;
                        case DateCalculatorSubtraction:
                          showDialog(
                              context: context,
                              builder: (context) => AddEventPage(
                                  dateTime: ClassUtils.tryCast<
                                          DateCalculatorSubtraction>(state)!
                                      .endDateDateTime));
                          break;
                      }
                    },
                    child: Card(
                        color: Theme.of(context).colorScheme.secondary,
                        shadowColor: Theme.of(context).colorScheme.primary,
                        child: Stack(children: [
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(state.resultTitle,
                                    style: JoysCalendarThemeData
                                        .lightThemeData.textTheme.subtitle2),
                              )),
                          Center(
                              child: Text(state.result,
                                  style: JoysCalendarThemeData
                                      .lightThemeData.textTheme.headline4))
                        ])),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Stack(children: [
                  Visibility(
                    visible: state is DateCalculatorInterval,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        InkWell(
                          onTap: () async {
                            var currentDate = state.startDate;
                            DateModel? pickedDate = await showDialog(
                                context: context,
                                builder: (context) {
                                  if (currentDate.isLunar) {
                                    return DefaultDatePickerDialog
                                        .fromLunarDate(currentDate.year,
                                            currentDate.month, currentDate.day);
                                  } else {
                                    return DefaultDatePickerDialog.fromDate(
                                        currentDate.year,
                                        currentDate.month,
                                        currentDate.day);
                                  }
                                });

                            if (!mounted) {
                              return;
                            }
                            if (pickedDate != null) {
                              context
                                  .read<DateCalculatorCubit>()
                                  .changeToInterval(
                                      startDate: pickedDate,
                                      endDate: (state as DateCalculatorInterval)
                                          .endDate);
                            }
                          },
                          child: TextField(
                            enabled: false,
                            controller: TextEditingController(
                                text:
                                    ClassUtils.tryCast<DateCalculatorInterval>(
                                            state)
                                        ?.startDateString),
                            decoration: InputDecoration(
                                labelText: '開始日期',
                                labelStyle:
                                    Theme.of(context).textTheme.headline6!,
                                suffixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Stack(children: [
                          InkWell(
                            onTap: () async {
                              var currentDate =
                                  ClassUtils.tryCast<DateCalculatorInterval>(
                                          state)
                                      ?.endDate;
                              DateModel? pickedDate = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    if (currentDate?.isLunar == true) {
                                      return DefaultDatePickerDialog
                                          .fromLunarDate(
                                              currentDate!.year,
                                              currentDate.month,
                                              currentDate.day);
                                    } else {
                                      return DefaultDatePickerDialog.fromDate(
                                          currentDate?.year ??
                                              DateTime.now().year,
                                          currentDate?.month ??
                                              DateTime.now().month,
                                          currentDate?.day ??
                                              DateTime.now().day);
                                    }
                                  });

                              if (!mounted) {
                                return;
                              }

                              if (pickedDate != null) {
                                context
                                    .read<DateCalculatorCubit>()
                                    .changeToInterval(
                                        startDate: state.startDate,
                                        endDate: pickedDate);
                              }
                            },
                            child: TextField(
                                enabled: false,
                                controller: TextEditingController(
                                    text: ClassUtils.tryCast<
                                            DateCalculatorInterval>(state)
                                        ?.endDateString),
                                decoration: InputDecoration(
                                  labelText: '結束日期',
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  labelStyle:
                                      Theme.of(context).textTheme.headline6!,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                )),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: state is DateCalculatorAddition,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            var currentDate = state.startDate;
                            DateModel? pickedDate = await showDialog(
                                context: context,
                                builder: (context) {
                                  return DefaultDatePickerDialog.fromDate(
                                      currentDate.year,
                                      currentDate.month,
                                      currentDate.day);
                                });

                            if (!mounted) {
                              return;
                            }

                            if (pickedDate != null) {
                              context
                                  .read<DateCalculatorCubit>()
                                  .changeToAddition(startDate: pickedDate);
                            }
                          },
                          child: TextField(
                            enabled: false,
                            controller: TextEditingController(
                                text:
                                    ClassUtils.tryCast<DateCalculatorAddition>(
                                            state)
                                        ?.startDateString),
                            decoration: InputDecoration(
                                labelText: '開始日期',
                                labelStyle:
                                    Theme.of(context).textTheme.headline6!,
                                suffixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            NumberPicker(
                                title: '年',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToAddition(addYearValue: value);
                                }),
                            NumberPicker(
                                title: '月',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToAddition(addMonthValue: value);
                                }),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            NumberPicker(
                                title: '日',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToAddition(addDayValue: value);
                                }),
                            NumberPicker(
                                title: '週',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToAddition(addWeekValue: value);
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: state is DateCalculatorSubtraction,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            var currentDate = state.startDate;
                            DateModel? pickedDate = await showDialog(
                                context: context,
                                builder: (context) {
                                  return DefaultDatePickerDialog.fromDate(
                                      currentDate.year,
                                      currentDate.month,
                                      currentDate.day);
                                });

                            if (!mounted) {
                              return;
                            }

                            if (pickedDate != null) {
                              context
                                  .read<DateCalculatorCubit>()
                                  .changeToSubtraction(startDate: pickedDate);
                            }
                          },
                          child: TextField(
                            enabled: false,
                            controller: TextEditingController(
                                text: ClassUtils.tryCast<
                                        DateCalculatorSubtraction>(state)
                                    ?.startDateString),
                            decoration: InputDecoration(
                                labelText: '開始日期',
                                labelStyle:
                                    Theme.of(context).textTheme.headline6!,
                                suffixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            NumberPicker(
                                title: '年',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToSubtraction(subYearValue: value);
                                }),
                            NumberPicker(
                                title: '月',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToSubtraction(
                                          subMonthValue: value);
                                }),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            NumberPicker(
                                title: '日',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToSubtraction(subDayValue: value);
                                }),
                            NumberPicker(
                                title: '週',
                                initialValue: 0,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (value) {
                                  context
                                      .read<DateCalculatorCubit>()
                                      .changeToSubtraction(subWeekValue: value);
                                }),
                          ],
                        ),
                      ],
                    ),
                  )
                ]),
              ),
              const SizedBox(height: 4),
              CupertinoSegmentedControl(
                  selectedColor: Theme.of(context).colorScheme.primary,
                  unselectedColor: Theme.of(context).colorScheme.surface,
                  groupValue: state.runtimeType,
                  children: const {
                    DateCalculatorInterval: Padding(
                        padding: EdgeInsets.all(10), child: Text('計算間隔天數')),
                    DateCalculatorAddition: Text('添加天數'),
                    DateCalculatorSubtraction: Text('減去天數'),
                  },
                  onValueChanged: (state) {
                    var now = DateTime.now();
                    switch (state) {
                      case DateCalculatorInterval:
                        context.read<DateCalculatorCubit>().changeToInterval(
                            startDate: DateModel(
                                year: now.year,
                                month: now.month,
                                day: now.day,
                                isLunar: false),
                            endDate: null);
                        break;
                      case DateCalculatorAddition:
                        context.read<DateCalculatorCubit>().changeToAddition(
                            startDate: DateModel(
                                year: now.year,
                                month: now.month,
                                day: now.day,
                                isLunar: false));
                        break;
                      case DateCalculatorSubtraction:
                        context.read<DateCalculatorCubit>().changeToSubtraction(
                            startDate: DateModel(
                                year: now.year,
                                month: now.month,
                                day: now.day,
                                isLunar: false));
                        break;
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
