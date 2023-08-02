import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/extentions/calendar_event_extensions.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/common/button_style.dart';
import 'package:joys_calendar/view/common/event_chip_view.dart';
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
  final GlobalKey _titleKey = GlobalKey();
  var _titleTextWidth = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _titleKey.currentContext;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        setState(() => _titleTextWidth = box.size.width);
      }
    });
  }

  @override
  Widget build(BuildContext rootContext) {
    return BlocProvider(
      create: (context) => HomeCubit(context.read<CalendarEventRepository>())
        ..getEventWhenAppLaunch(),
      child: Builder(builder: (scaffoldContext) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(key: _titleKey, widget.title),
            actions: [
              AnimSearchBar(
                boxShadow: false,
                width: MediaQuery.of(context).size.width - _titleTextWidth - 45,
                textController: textEditingController,
                helpText: '搜尋關鍵字',
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
                  label: "新增我的記事",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.add),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;
                        var isAdded = await showDialog(
                            context: context,
                            builder: (context) => AddEventPage());
                        if (!mounted) {
                          return;
                        }
                        if (isAdded == true) {
                          scaffoldContext
                              .read<HomeCubit>()
                              .refreshFromAddOrUpdateCustomEvent();
                        }
                      })),
              SpeedDialChild(
                  label: "我的記事列表",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.list_alt),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;
                        await Navigator.pushNamed(
                            context, AppConstants.routeMyEvent);
                        if (!mounted) {
                          return;
                        }
                        scaffoldContext
                            .read<HomeCubit>()
                            .refreshFromAddOrUpdateCustomEvent();
                      })),
              SpeedDialChild(
                  label: "設定",
                  child: FloatingActionButton.small(
                      child: const Icon(Icons.settings_outlined),
                      onPressed: () async {
                        isDialOpen.value = !isDialOpen.value;
                        await Navigator.of(rootContext)
                            .pushNamed(AppConstants.routeSettings);
                        if (!mounted) return;
                        scaffoldContext
                            .read<HomeCubit>()
                            .refreshAllEventsFromSettings();
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
                  final yearString =
                      DateFormat('西元 y年', AppConstants.defaultLocale)
                          .format(datetime!);
                  final monthString =
                      DateFormat('MMMM', AppConstants.defaultLocale)
                          .format(datetime);
                  Lunar lunar = Lunar.fromDate(datetime);
                  final ganZhi = lunar.getYearInGanZhi();
                  final shenXiao = lunar.getYearShengXiao();
                  String minkuoYearString = "";
                  if (datetime.year - 1911 >= 0) {
                    final minkuoYear = datetime.year - 1911;
                    minkuoYearString = "民國 $minkuoYear年";
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("$yearString $minkuoYearString"),
                            Text("$monthString $ganZhi $shenXiao"),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    if (currentDate.month == 1) {
                                      currentDate = DateTime(
                                          currentDate.year - 1,
                                          DateTime.december);
                                    } else {
                                      currentDate = DateTime(currentDate.year,
                                          currentDate.month - 1);
                                    }
                                  });
                                  cellCalendarPageController.animateToDate(
                                      currentDate,
                                      curve: Curves.linear,
                                      duration:
                                          const Duration(milliseconds: 300));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.navigate_before),
                                )),
                            currentDate.year == DateTime.now().year &&
                                    currentDate.month == DateTime.now().month
                                ? InkWell(
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.edit_calendar),
                                    ),
                                    onTap: () async {
                                      final pickedDate =
                                          await showMonthYearPicker(
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
                                        cellCalendarPageController
                                            .animateToDate(
                                          currentDate,
                                          curve: Curves.linear,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );
                                      }
                                    })
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        currentDate = DateTime.now();
                                      });
                                      cellCalendarPageController.animateToDate(
                                        currentDate,
                                        curve: Curves.linear,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.calendar_today),
                                    )),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    if (currentDate.month == 12) {
                                      currentDate = DateTime(
                                          currentDate.year + 1,
                                          DateTime.january);
                                    } else {
                                      currentDate = DateTime(currentDate.year,
                                          currentDate.month + 1);
                                    }
                                  });
                                  cellCalendarPageController.animateToDate(
                                      currentDate,
                                      curve: Curves.linear,
                                      duration:
                                          const Duration(milliseconds: 300));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.navigate_next),
                                )),
                          ],
                        ),
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
                    } else if (aOrder < bOrder) {
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
                  final dateFormat = DateFormat(
                      DateFormat.ABBR_MONTH_WEEKDAY_DAY,
                      AppConstants.defaultLocale);
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          actionsAlignment: MainAxisAlignment.center,
                          titlePadding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                          contentPadding:
                              const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 80) *
                                          0.6,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      dateFormat.format(date),
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 80) *
                                          0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: OutlinedButton.icon(
                                          style: appTitleButtonStyle(),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            var isAdded = await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AddEventPage(
                                                        dateTime: date));
                                            if (!mounted) {
                                              return;
                                            }
                                            if (isAdded == true) {
                                              context
                                                  .read<HomeCubit>()
                                                  .refreshFromAddOrUpdateCustomEvent();
                                            }
                                          },
                                          icon: const Icon(Icons.add),
                                          label: Text("新增記事",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .button!)),
                                    ),
                                  ),
                                )
                              ]),
                          content: SizedBox.fromSize(
                            size: const Size(300, 300),
                            child: ListView.separated(
                                itemBuilder: (context, index) {
                                  final event = dayEvents[index];
                                  return ListTile(
                                    leading: EventChipView(
                                        eventName: event
                                            .getEventType()
                                            .toInfoDialogName(),
                                        eventColor: event.eventBackgroundColor),
                                    title: Text(event.eventName,
                                        style: TextStyle(
                                            color: event.eventTextStyle.color)),
                                    onTap: () {},
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemCount: dayEvents.length),
                          )));
                },
                onPageChanged: (firstDate, lastDate) {
                  /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
                  final diff =
                      firstDate.difference(lastDate).inMilliseconds ~/ 2;
                  final midDate = DateTime.fromMillisecondsSinceEpoch(
                      lastDate.millisecondsSinceEpoch + diff);
                  setState(() {
                    currentDate = midDate;
                    updateLunarAndSolar(cubit);
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

  void updateLunarAndSolar(HomeCubit cubit) {
    cubit.refreshWhenYearChanged(currentDate.year);
  }
}
