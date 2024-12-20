import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/analytics/analytics_events.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/common/extentions/calendar_event_extensions.dart';
import 'package:joys_calendar/common/extentions/date_time_extensions.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/common/utils/notification_helper.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/common/button_style.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';
import 'package:joys_calendar/view/common/date_picker/default_date_picker_dialog.dart';
import 'package:joys_calendar/view/common/days_of_the_week_builder.dart';
import 'package:joys_calendar/view/common/event_chip_view.dart';
import 'package:joys_calendar/view/home/home_cubit.dart';
import 'package:joys_calendar/view/search_result/event_search_delegate.dart';

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
    final analyticsHelper = context.read<AnalyticsHelper>();
    return BlocProvider(
      create: (context) => HomeCubit(context.read<CalendarEventRepository>(),
          context.read<SharedPreferenceProvider>(),
          context.read<NotificationHelper>())
        ..getEventWhenAppLaunch(),
      child: Builder(builder: (scaffoldContext) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/joys-calendar-icon.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 4),
                Text(widget.title),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    analyticsHelper.logEvent(name: event_search);
                    await showSearch(
                        context: context,
                        delegate: EventSearchDelegate(
                            context.read<CalendarEventRepository>(),
                            context
                                .read<SharedPreferenceProvider>()
                                .getSavedCalendarEvents()
                                .contains(EventType.lunar)));

                    if (!mounted) {
                      return;
                    }
                    scaffoldContext
                        .read<HomeCubit>()
                        .refreshFromAddOrUpdateCustomEvent();
                  },
                  icon: const Icon(Icons.search)),
            ],
          ),
          body: HomeCalendarPage(),
          floatingActionButton: SpeedDial(
            icon: Icons.menu_rounded,
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      child: const Icon(Icons.add),
                      onPressed: () async {
                        analyticsHelper
                            .logEvent(name: event_add_event, parameters: {
                          event_add_event_params_position_name:
                              event_add_event_params_position.menu.toString()
                        });
                        analyticsHelper
                            .logEvent(name: event_home_menu, parameters: {
                          event_home_menu_params_feature_name:
                              event_home_menu_params_feature.add_event
                                  .toString()
                        });
                        isDialOpen.value = !isDialOpen.value;
                        var isAdded = await showDialog(
                            barrierDismissible: false,
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      child: const Icon(Icons.list_alt),
                      onPressed: () async {
                        analyticsHelper
                            .logEvent(name: event_home_menu, parameters: {
                          event_home_menu_params_feature_name:
                              event_home_menu_params_feature.my_event.toString()
                        });
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
                  label: "日期計算器",
                  child: FloatingActionButton.small(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      child: const Icon(Icons.calculate_outlined),
                      onPressed: () async {
                        // TODO Analytics
                        isDialOpen.value = !isDialOpen.value;
                        await Navigator.of(rootContext)
                            .pushNamed(AppConstants.routeDateCalculator);
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      child: const Icon(Icons.settings_outlined),
                      onPressed: () async {
                        analyticsHelper
                            .logEvent(name: event_home_menu, parameters: {
                          event_home_menu_params_feature_name:
                              event_home_menu_params_feature.setting.toString()
                        });
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

class _HomeCalendarPageState extends State<HomeCalendarPage>
    with WidgetsBindingObserver {
  final CellCalendarPageController cellCalendarPageController =
      CellCalendarPageController();

  var currentDate = DateTime(MyHomePage.now.year, MyHomePage.now.month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 每次回前景時觸發更新，解決UI停留到隔日後，返回App日曆的今天UI沒有更新問題
      context.read<HomeCubit>().refreshAllEventsFromSettings();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext parentContext) {
    final state = parentContext.watch<HomeCubit>().state;
    final cubit = parentContext.read<HomeCubit>();
    final analyticsHelper = parentContext.read<AnalyticsHelper>();
    switch (state.status) {
      case HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case HomeStatus.success:
      case HomeStatus.title:
        return CellCalendar(
          todayMarkColor: Theme.of(parentContext).colorScheme.primary,
          cellCalendarPageController: cellCalendarPageController,
          events: state.events,
          daysOfTheWeekBuilder: daysOfTheWeekBuilder,
          monthYearLabelBuilder: (datetime) {
            final yearString = DateFormat('西元 y年', AppConstants.defaultLocale)
                .format(datetime!);
            final monthString =
                DateFormat('MMMM', AppConstants.defaultLocale).format(datetime);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("$yearString ${datetime.yearOfRoc}"),
                        Text(
                            "$monthString ${datetime.ganZhi} ${datetime.shenXiao}"),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: InkWell(
                              onTap: () {
                                analyticsHelper.logEvent(
                                    name: event_previous_month);
                                setState(() {
                                  if (currentDate.month == 1) {
                                    currentDate = DateTime(currentDate.year - 1,
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
                              child: const Icon(Icons.navigate_before)),
                        ),
                        currentDate.year == DateTime.now().year &&
                                currentDate.month == DateTime.now().month
                            ? InkWell(
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.edit_calendar),
                                ),
                                onTap: () async {
                                  analyticsHelper.logEvent(
                                      name: event_select_date,
                                      parameters: {
                                        event_select_date_params_position_name:
                                            event_select_date_params_position
                                                .home
                                                .toString()
                                      });
                                  DateModel? pickedDate = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DefaultDatePickerDialog.fromDate(
                                            currentDate.year,
                                            currentDate.month,
                                            null);
                                      });
                                  if (!mounted) {
                                    return;
                                  }
                                  if (pickedDate != null) {
                                    setState(() {
                                      if (pickedDate.isLunar) {
                                        var solar = pickedDate.toSolar();
                                        currentDate = DateTime(solar.getYear(),
                                            solar.getMonth(), solar.getDay());
                                      } else {
                                        currentDate = DateTime(
                                            pickedDate.year,
                                            pickedDate.month,
                                            pickedDate.day ?? 1);
                                      }
                                    });
                                    cellCalendarPageController.animateToDate(
                                      currentDate,
                                      curve: Curves.linear,
                                      duration:
                                          const Duration(milliseconds: 300),
                                    );
                                  }
                                })
                            : InkWell(
                                onTap: () {
                                  analyticsHelper.logEvent(
                                      name: event_back_to_today);
                                  setState(() {
                                    currentDate = DateTime.now();
                                  });
                                  cellCalendarPageController.animateToDate(
                                    currentDate,
                                    curve: Curves.linear,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.calendar_today),
                                )),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: InkWell(
                              onTap: () {
                                analyticsHelper.logEvent(
                                    name: event_next_month);
                                setState(() {
                                  if (currentDate.month == 12) {
                                    currentDate = DateTime(
                                        currentDate.year + 1, DateTime.january);
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
                              child: const Icon(Icons.navigate_next)),
                        ),
                      ],
                    ),
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
                DateFormat.ABBR_MONTH_WEEKDAY_DAY, AppConstants.defaultLocale);
            showDialog(
                context: parentContext,
                builder: (_) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    actionsAlignment: MainAxisAlignment.center,
                    insetPadding: const EdgeInsets.all(8.0),
                    titlePadding:
                        const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    contentPadding:
                        const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                    title: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              dateFormat.format(date),
                              style:
                                  Theme.of(parentContext).textTheme.headlineMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: OutlinedButton.icon(
                                  style: appTitleButtonStyle(),
                                  onPressed: () async {
                                    analyticsHelper.logEvent(
                                        name: event_add_event,
                                        parameters: {
                                          event_add_event_params_position_name:
                                              event_add_event_params_position
                                                  .dialog
                                                  .toString()
                                        });
                                    Navigator.pop(parentContext);
                                    var isAdded = await showDialog(
                                        context: parentContext,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            AddEventPage(dateTime: date));
                                    if (!mounted) {
                                      return;
                                    }
                                    if (isAdded == true) {
                                      parentContext
                                          .read<HomeCubit>()
                                          .refreshFromAddOrUpdateCustomEvent();
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text("新增記事",
                                      style: Theme.of(parentContext)
                                          .textTheme
                                          .labelLarge!)),
                            ),
                          )
                        ]),
                    content: SizedBox(
                      width: MediaQuery.of(parentContext).size.width * 0.95,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: 200,
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.55),
                        child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final event = dayEvents[index];
                              return ListTile(
                                leading: EventChipView(
                                    eventName:
                                        event.getEventType().toInfoDialogName(),
                                    eventColor: event.eventBackgroundColor),
                                title: Text(event.eventName,
                                    style: TextStyle(
                                        color: event.eventTextStyle.color)),
                                onTap: () async {
                                  if (event.extractEventTypeName() ==
                                      EventType.custom.name) {
                                    analyticsHelper.logEvent(
                                        name: event_edit_my_event,
                                        parameters: {
                                          event_edit_my_event_params_position_name:
                                              event_edit_my_event_params_position
                                                  .dialog.name
                                        });
                                    Navigator.pop(context);
                                    dynamic id = int.tryParse(
                                        event.extractEventIdForModify());
                                    var isAdded = await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            AddEventPage(memoModelKey: id));
                                    if (!mounted) {
                                      return;
                                    }
                                    if (isAdded == true) {
                                      parentContext
                                          .read<HomeCubit>()
                                          .refreshFromAddOrUpdateCustomEvent();
                                    }
                                  }
                                },
                                onLongPress: () {
                                  debugPrint('[Tony] onLongPress $event');
                                  parentContext
                                      .read<HomeCubit>()
                                      .copyEventToClipboard(event);
                                  Fluttertoast.showToast(
                                      msg: "複製成功",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                },
                              );
                            },
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.grey[300],),
                            itemCount: dayEvents.length),
                      ),
                    )));
          },
          onPageChanged: (firstDate, lastDate) {
            /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
            final diff = firstDate.difference(lastDate).inMilliseconds ~/ 2;
            final midDate = DateTime.fromMillisecondsSinceEpoch(
                lastDate.millisecondsSinceEpoch + diff);
            debugPrint('[Tony] onPageChanged: $midDate, $firstDate, $lastDate');
            currentDate = midDate;
            updateLunarAndSolar(cubit);
          },
          dateTextStyle: JoysCalendarThemeData.calendarTextTheme.bodyMedium,
        );
    }
  }

  void updateLunarAndSolar(HomeCubit cubit) {
    cubit.refreshWhenYearChanged(currentDate.year);
  }
}
