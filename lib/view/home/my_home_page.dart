import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/home/home_cubit.dart';
import 'package:joys_calendar/view/search_result/search_result_argument.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../common/constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  static DateTime now = DateTime.now();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var isDialOpen = ValueNotifier<bool>(false);
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext rootContext) {
    return BlocProvider(
      create: (context) => HomeCubit(context.read<CalendarEventRepository>())
        ..getEventFirstTime(),
      child: Builder(builder: (scaffoldContext) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              AnimSearchBar(
                boxShadow: false,
                autoFocus: true,
                width: MediaQuery.of(context).size.width,
                textController: textEditingController,
                onSuffixTap: () {},
                onSubmitted: (text) {
                  Navigator.of(rootContext).pushNamed(
                      AppConstants.routeSearchResult,
                      arguments: SearchResultArguments(text));
                },
              )
            ],
          ),
          body: HomeCalendarPage(),
          floatingActionButton: SpeedDial(
            icon: Icons.menu_rounded,
            activeIcon: Icons.close,
            spacing: 3,
            overlayOpacity: 0,
            openCloseDial: isDialOpen,
            childPadding: const EdgeInsets.all(5),
            spaceBetweenChildren: 4,
            children: [
              SpeedDialChild(
                  label: "新增",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.event_note),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;
                        var isAdded = await showDialog(
                            context: context,
                            builder: (context) => AddEventPage());

                        if (!mounted) {
                          return;
                        }
                        if (isAdded == true) {
                          scaffoldContext.read<HomeCubit>().refreshFromAddOrUpdateCustomEvent();
                        }
                      })),
              SpeedDialChild(
                  label: "我的日曆列表",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.list_alt_outlined),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;
                        await Navigator.pushNamed(context, AppConstants.routeMyEvent);
                        if (!mounted) {
                          return;
                        }
                        scaffoldContext.read<HomeCubit>().refreshFromAddOrUpdateCustomEvent();
                      })),
              SpeedDialChild(
                  label: "設定",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.settings),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;
                        await Navigator.of(rootContext)
                            .pushNamed(AppConstants.routeSettings);
                        if (!mounted) return;
                        scaffoldContext.read<HomeCubit>().refreshGoogleCalendarHolidaysFromSettings();
                      })),
            ],
          ),
        );
      }),
    );
  }
}

class HomeCalendarPage extends StatefulWidget {
  HomeCalendarPage({Key? key}) : super(key: key);

  @override
  State<HomeCalendarPage> createState() => _HomeCalendarPageState();
}

class _HomeCalendarPageState extends State<HomeCalendarPage> {
  final CellCalendarPageController cellCalendarPageController =
      CellCalendarPageController();

  var currentDate = DateTime(MyHomePage.now.year, MyHomePage.now.month);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeCubit>().state;
    final cubit = context.read<HomeCubit>();
    switch (state.status) {
      case HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case HomeStatus.success:
      case HomeStatus.title:
        return Column(
          children: [
            Expanded(
              child: CellCalendar(
                todayMarkColor: Theme.of(context).colorScheme.primary,
                cellCalendarPageController: cellCalendarPageController,
                events: state.events,
                daysOfTheWeekBuilder: (dayIndex) {
                  final labels = ["日", "一", "二", "三", "四", "五", "六"];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      labels[dayIndex],
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                monthYearLabelBuilder: (datetime) {
                  final dateString =
                      DateFormat('y MMMM', AppConstants.defaultLocale)
                          .format(datetime!);
                  Lunar lunar = Lunar.fromDate(datetime);
                  final ganZhi = lunar.getYearInGanZhi();
                  final shenXiao = lunar.getYearShengXiao();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text("$dateString $ganZhi $shenXiao"),
                        const Spacer(),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.navigate_before),
                            onPressed: () {
                              setState(() {
                                if (currentDate.month == 1) {
                                  currentDate = DateTime(
                                      currentDate.year - 1, DateTime.december);
                                } else {
                                  currentDate = DateTime(
                                      currentDate.year, currentDate.month - 1);
                                }
                              });
                              cellCalendarPageController.animateToDate(
                                  currentDate,
                                  curve: Curves.linear,
                                  duration: const Duration(milliseconds: 300));
                            }),
                        currentDate.year == DateTime.now().year &&
                                currentDate.month == DateTime.now().month
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_calendar),
                                onPressed: () async {
                                  final pickedDate = await showMonthYearPicker(
                                      context: context,
                                      initialMonthYearPickerMode:
                                          MonthYearPickerMode.month,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100));
                                  if (!mounted) {
                                    return;
                                  }
                                  if (pickedDate != null) {
                                    setState(() {
                                      currentDate = pickedDate;
                                    });
                                    cellCalendarPageController.animateToDate(
                                      currentDate,
                                      curve: Curves.linear,
                                      duration:
                                          const Duration(milliseconds: 300),
                                    );
                                  }
                                },
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () {
                                  setState(() {
                                    currentDate = DateTime.now();
                                  });
                                  cellCalendarPageController.animateToDate(
                                    currentDate,
                                    curve: Curves.linear,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                              ),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.navigate_next),
                            onPressed: () {
                              setState(() {
                                if (currentDate.month == 12) {
                                  currentDate = DateTime(
                                      currentDate.year + 1, DateTime.january);
                                } else {
                                  currentDate = DateTime(
                                      currentDate.year, currentDate.month + 1);
                                }
                              });
                              cellCalendarPageController.animateToDate(
                                  currentDate,
                                  curve: Curves.linear,
                                  duration: const Duration(milliseconds: 300));
                            }),
                      ],
                    ),
                  );
                },
                onCellTapped: (date) {
                  var newList = state.events.toList();
                  newList.sort((a, b) {
                    var aOrder = a.order ?? 0;
                    var bOrder = b.order ?? 0;
                    if (aOrder > bOrder) {
                      return 1;
                    } else if(aOrder < bOrder) {
                      return -1;
                    } else {
                      return 0;
                    }
                  });
                  final dayEvents = newList.where((event) {
                    final eventDate = event.eventDate;
                    return eventDate.year == date.year &&
                        eventDate.month == date.month &&
                        eventDate.day == date.day;
                  }).toList();
                  final dateFormat = DateFormat(DateFormat.ABBR_MONTH_WEEKDAY_DAY, AppConstants.defaultLocale);
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text(dateFormat.format(date), style: Theme.of(context).textTheme.headline4,),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: dayEvents
                                  .map(
                                    (event) => Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(4),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      color: event.eventBackgroundColor,
                                      child: Text(
                                        event.eventName,
                                        style: TextStyle(
                                            color: event.eventTextStyle.color),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ));
                },
                onPageChanged: (firstDate, lastDate) {
                  /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
                  final diff =
                      firstDate.difference(lastDate).inMilliseconds ~/ 2;
                  final midDate = DateTime.fromMillisecondsSinceEpoch(
                      lastDate.millisecondsSinceEpoch + diff);
                  setState(() {
                    currentDate = midDate;
                  });
                },
                dateTextStyle:
                    JoysCalendarThemeData.calendarTextTheme.bodyText2,
              ),
            ),
          ],
        );
    }
  }
}
