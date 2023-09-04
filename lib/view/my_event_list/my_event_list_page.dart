import 'package:easy_sticky_header/easy_sticky_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/analytics/analytics_events.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/common/configs/colors.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/extentions/date_time_extensions.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_cubit.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_item_page.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_state.dart';

class MyEventListPage extends StatefulWidget {
  const MyEventListPage({Key? key}) : super(key: key);

  @override
  State<MyEventListPage> createState() => _MyEventListPageState();
}

class _MyEventListPageState extends State<MyEventListPage> {
  late StickyHeaderController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = StickyHeaderController();
    _scrollController = ScrollController();
    _scrollController.addListener(() {});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<MyEventListCubit>().load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsHelper = context.read<AnalyticsHelper>();
    final myEventState = context.watch<MyEventListCubit>().state;
    var isDeleting =
        myEventState.myEventListStatus == MyEventListStatus.deleting;
    var hasDeleteCount = myEventState.checkedCount != 0;
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              child: isDeleting
                  ? const Center(child: Text('取消'))
                  : const Icon(Icons.arrow_back),
              onTap: () {
                if (isDeleting) {
                  context.read<MyEventListCubit>().cancelDeleting();
                } else {
                  Navigator.of(context).pop();
                }
              }),
          title: isDeleting
              ? Text('刪除(${myEventState.checkedCount}筆)')
              : const Text('我的記事列表'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                  child: isDeleting
                      ? Icon(Icons.delete,
                          color: hasDeleteCount ? Colors.green : Colors.black26)
                      : const Icon(Icons.edit),
                  onTap: () async {
                    if (!isDeleting) {
                      context.read<MyEventListCubit>().startDeleting();
                    } else {
                      if (!hasDeleteCount) return;
                      analyticsHelper.logEvent(
                          name: event_delete_my_event,
                          parameters: {
                            event_delete_my_event_params_count_name:
                                myEventState.checkedCount
                          });
                      await context.read<MyEventListCubit>().delete();
                    }
                  }),
            )
          ],
          elevation: 0.5,
        ),
        body: NotificationListener(
          onNotification: (t) {
            if (t is ScrollEndNotification) {}
            if (t is ScrollUpdateNotification) {
              final itemSize =
                  (context.findRenderObject() as RenderBox).size.height;
            }
            return false;
          },
          child: StickyHeader(
            controller: _controller,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: myEventState.myEventList.length,
              itemBuilder: (BuildContext context, int index) {
                var itemDateTime = myEventState.myEventList[index].dateTime;
                if (myEventState.myEventList[index].key == -2) {
                  final date =
                      DateFormat(DateFormat.YEAR, AppConstants.defaultLocale)
                          .format(itemDateTime);
                  return StickyContainerWidget(
                    index: index,
                    child: Container(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      child: ListTile(
                        title: Text(
                            '西元 $date ${itemDateTime.yearOfRoc} ${itemDateTime.ganZhi} ${itemDateTime.shenXiao}',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!)
                      ),
                    ),
                  );
                }

                if (myEventState.myEventList[index].key == -1) {
                  var previousIsHeader = index > 0
                      ? myEventState.myEventList[index - 1].key == -1 ||
                      myEventState.myEventList[index - 1].key == -2
                      : false;
                  final date = DateFormat(
                          DateFormat.MONTH_DAY, AppConstants.defaultLocale)
                      .format(itemDateTime);

                  final weekday =
                      DateFormat(DateFormat.WEEKDAY, AppConstants.defaultLocale)
                          .format(itemDateTime);
                  return Column(
                    children: [
                      previousIsHeader
                          ? const SizedBox.shrink()
                          : Divider(
                              height: 10,
                              thickness: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                      ListTile(
                        title: Text('$date $weekday',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                }
                return InkWell(
                  onTap: () async {
                    if (isDeleting ||
                        myEventState.myEventList[index].memo.isEmpty) {
                      return;
                    }

                    analyticsHelper
                        .logEvent(name: event_edit_my_event, parameters: {
                      event_edit_my_event_params_position_name:
                          event_edit_my_event_params_position.my_event.name
                    });
                    bool? isUpdated = await showDialog(
                        context: context,
                        builder: (context) => AddEventPage(
                            memoModelKey: myEventState.myEventList[index].key));
                    if (!mounted) {
                      return;
                    }
                    if (isUpdated == true) {
                      context.read<MyEventListCubit>().load();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: MyEventListItemPage(
                        myEventState.myEventList[index], index,
                        (index, isChecked) {
                      context
                          .read<MyEventListCubit>()
                          .updateChecked(index, isChecked);
                    }, isDeleting, key: ValueKey<String>(index.toString())),
                  ),
                );
              },
              findChildIndexCallback: (Key key) {
                final ValueKey<String> valueKey = key as ValueKey<String>;
                return int.parse(valueKey.value);
              },
              separatorBuilder: (BuildContext context, int index) {
                var model = myEventState.myEventList[index];
                var nextIsHeader = index < myEventState.myEventList.length - 1
                    ? myEventState.myEventList[index + 1].key == -1 ||
                        myEventState.myEventList[index + 1].key == -2
                    : false;
                if (model.key == -1 || model.key == -2 || nextIsHeader) {
                  return const SizedBox.shrink();
                } else {
                  return const Divider(
                    height: 10,
                    indent: 20,
                    endIndent: 20,
                  );
                }
              },
            ),
          ),
        ));
  }
}
