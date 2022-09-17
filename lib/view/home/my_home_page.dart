import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/view/home/home_cubit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  static DateTime now = DateTime.now();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext rootContext) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(context.read<CalendarEventRepository>())..getEvents(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                  onPressed: () async {
                    await Navigator.of(rootContext).pushNamed("/settings");
                    context.read<HomeCubit>().getEvents();
                  },
                  icon: const Icon(Icons.settings));
            })
          ],
        ),
        body: HomeCalendarPage(),
      ),
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
                  // TODO 顯示生肖、甲子年
                  final year = datetime!.year.toString();
                  final month = datetime.month.monthName;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          "$month  $year",
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
