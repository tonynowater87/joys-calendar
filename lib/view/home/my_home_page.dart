import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/home/home_cubit.dart';
import 'package:lunar/lunar.dart';

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

  @override
  Widget build(BuildContext rootContext) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(context.read<CalendarEventRepository>())..getEvents(),
      child: Builder(builder: (scaffoldContext) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                    onPressed: () async {
                      await Navigator.of(rootContext)
                          .pushNamed(AppConstants.routeSettings);
                      if (!mounted) return;
                      context.read<HomeCubit>().getEvents();
                    },
                    icon: const Icon(Icons.settings));
              })
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
                  label: "??????",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.event_note),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;
                        bool? isAdded = await showDialog(
                            context: context,
                            builder: (context) => AddEventPage()
                        );

                        if (!mounted) {
                          return;
                        }
                        if (isAdded == true) {
                          scaffoldContext.read<HomeCubit>().getEvents();
                        }
                      })),
              SpeedDialChild(
                  label: "??????????????????",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.list_alt_outlined),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;

                        var isUpdate = await Navigator.pushNamed(
                            context, AppConstants.routeMyEvent);

                        if (!mounted) {
                          return;
                        }

                        if (isUpdate == true) {
                          scaffoldContext.read<HomeCubit>().getEvents();
                        }
                      }))
            ],
          ),
        );
      }),
    );
  }
}

class HomeCalendarPage extends StatelessWidget {
  final CellCalendarPageController cellCalendarPageController =
      CellCalendarPageController();

  var currentDate = DateTime(MyHomePage.now.year, MyHomePage.now.month);

  HomeCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeCubit>().state;
    switch (state.status) {
      case HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case HomeStatus.failure:
        return const Center(
          child: Text('Oops something went wrong!'),
        );
      case HomeStatus.success:
        return Column(
          children: [
            Expanded(
              child: CellCalendar(
                todayMarkColor: Theme.of(context).colorScheme.primary,
                cellCalendarPageController: cellCalendarPageController,
                events: state.events,
                daysOfTheWeekBuilder: (dayIndex) {
                  final labels = ["???", "???", "???", "???", "???", "???", "???"];
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
                  final shenXiao = lunar.getYearShengXiao(); // TODO ?????????
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          "$dateString $ganZhi $shenXiao",
                        ),
                        const Spacer(),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.navigate_before),
                            onPressed: () {
                              if (currentDate.month == 1) {
                                currentDate = DateTime(
                                    currentDate.year - 1, DateTime.december);
                              } else {
                                currentDate = DateTime(
                                    currentDate.year, currentDate.month - 1);
                              }
                              cellCalendarPageController.animateToDate(
                                  currentDate,
                                  curve: Curves.linear,
                                  duration: const Duration(milliseconds: 300));
                            }),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () {
                            currentDate = DateTime.now();
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
                              if (currentDate.month == 12) {
                                currentDate = DateTime(
                                    currentDate.year + 1, DateTime.january);
                              } else {
                                currentDate = DateTime(
                                    currentDate.year, currentDate.month + 1);
                              }
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
                  final eventsOnTheDate = state.events.where((event) {
                    final eventDate = event.eventDate;
                    return eventDate.year == date.year &&
                        eventDate.month == date.month &&
                        eventDate.day == date.day;
                  }).toList();
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text("${date.month.monthName} ${date.day}"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: eventsOnTheDate
                                  .map(
                                    (event) => Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(4),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      color: event.eventBackgroundColor,
                                      child: Text(
                                        event.eventName,
                                        style: TextStyle(
                                            color: event.eventTextColor),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ));
                },
                onPageChanged: (firstDate, lastDate) {
                  /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
                },
                dateTextStyle:
                    JoysCalendarThemeData.calendarTextTheme.bodyMedium,
              ),
            ),
          ],
        );
    }
  }
}
