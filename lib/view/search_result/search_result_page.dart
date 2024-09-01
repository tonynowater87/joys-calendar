import 'package:easy_sticky_header/easy_sticky_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/analytics/analytics_events.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/extentions/date_time_extensions.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/search_result/search_result_argument.dart';
import 'package:joys_calendar/view/search_result/search_result_cubit.dart';
import 'package:joys_calendar/view/search_result/search_result_list_item_page.dart';
import 'package:joys_calendar/view/search_result/search_ui_model.dart';

@Deprecated('Use SearchDelegate instead')
class SearchResultPage extends StatefulWidget {
  const SearchResultPage({Key? key}) : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  SearchResultArguments? args;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<SearchResultCubit>().search(args!.keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsHelper = context.read<AnalyticsHelper>();
    args = ModalRoute.of(context)!.settings.arguments as SearchResultArguments;
    SearchResultState searchResultState =
        context.watch<SearchResultCubit>().state;

    Widget body;

    if (searchResultState.status == SearchStatus.loading) {
      body = const CircularProgressIndicator();
    } else if (searchResultState.status == SearchStatus.empty) {
      body = const Text('查無資料');
    } else {
      body = StickyHeader(
          child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                final item = searchResultState.events[index];
                switch (item.itemType) {
                  case ItemType.year:
                    final date =
                        DateFormat(DateFormat.YEAR, AppConstants.defaultLocale)
                            .format(item.eventModel.date);
                    return StickyContainerWidget(
                      index: index,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: ListTile(
                            title: Text(
                                '西元 $date ${item.eventModel.date.yearOfRoc} ${item.eventModel.date.ganZhi} ${item.eventModel.date.shenXiao}',
                                style: Theme.of(context).textTheme.headlineMedium!)),
                      ),
                    );
                  case ItemType.date:
                    var previousIsHeader = index > 0
                        ? searchResultState.events[index - 1].itemType ==
                                ItemType.year ||
                            searchResultState.events[index - 1].itemType ==
                                ItemType.date
                        : false;
                    final date = DateFormat(
                            DateFormat.MONTH_DAY, AppConstants.defaultLocale)
                        .format(item.eventModel.date);

                    final weekday = DateFormat(
                            DateFormat.WEEKDAY, AppConstants.defaultLocale)
                        .format(item.eventModel.date);
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
                                  .headlineSmall!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  case ItemType.event:
                    return InkWell(
                      onTap: () async {
                        if (item.eventModel.idForModify == null) {
                          return;
                        }
                        analyticsHelper
                            .logEvent(name: event_edit_my_event, parameters: {
                          event_edit_my_event_params_position_name:
                          event_edit_my_event_params_position.search.name
                        });
                        bool? isUpdated = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AddEventPage(
                                memoModelKey: item.eventModel.idForModify));
                        if (!mounted) {
                          return;
                        }
                        if (isUpdated == true) {
                          context.read<SearchResultCubit>().search(args!.keyword);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SearchResultListItemPage(item.eventModel),
                      ),
                    );
                }
              },
              separatorBuilder: (context, index) {
                var model = searchResultState.events[index];
                var nextIsHeader = index < searchResultState.events.length - 1
                    ? searchResultState.events[index + 1].itemType ==
                            ItemType.year ||
                        searchResultState.events[index + 1].itemType ==
                            ItemType.date
                    : false;
                if (model.itemType == ItemType.year ||
                    model.itemType == ItemType.date ||
                    nextIsHeader) {
                  return const SizedBox.shrink();
                } else {
                  return const Divider(
                    height: 10,
                    indent: 20,
                    endIndent: 20,
                  );
                }
              },
              itemCount: searchResultState.events.length));
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('搜尋 [ ${args?.keyword} ]'),
        ),
        body: Center(child: body));
  }
}
