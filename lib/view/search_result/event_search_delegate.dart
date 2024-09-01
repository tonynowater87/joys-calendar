import 'package:easy_sticky_header/easy_sticky_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/extentions/date_time_extensions.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/view/add_event/add_event_page.dart';
import 'package:joys_calendar/view/search_result/search_result_list_item_page.dart';
import 'package:joys_calendar/view/search_result/search_ui_model.dart';

class EventSearchDelegate extends SearchDelegate<SearchUiModel> {
  CalendarEventRepository calendarRepository;

  EventSearchDelegate(this.calendarRepository);

  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    return null;
    // // check if the search bar is empty
    // if (query.isNotEmpty) {
    //   return null;
    // }
    //
    // // TODO show filter options
    // return PreferredSize(
    //     child: Container(
    //       color: Colors.amber,
    //       child: const Text('filter options'),
    //     ),
    //     preferredSize: const Size(40.0, 200));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext delegateContext) {
    return FutureBuilder<List<SearchUiModel>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data?.isEmpty == true) {
            return Container(
              alignment: Alignment.center,
              child: const Text('查無資料'),
            );
          } else {
            final events = snapshot.data!;
            return StickyHeader(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      final item = events[index];
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
                              ? events[index - 1].itemType ==
                              ItemType.year ||
                              events[index - 1].itemType ==
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
                              bool? isUpdated = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AddEventPage(
                                      memoModelKey: item.eventModel.idForModify));
                              if (isUpdated == true) {
                                // workaround for updating search result list after event updated
                                var tempQuery = query;
                                query = "";
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  query = tempQuery;
                                });
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
                      var model = events[index];
                      var nextIsHeader = index < events.length - 1
                          ? events[index + 1].itemType ==
                          ItemType.year ||
                          events[index + 1].itemType ==
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
                    itemCount: events.length));
          }
        },
        future: query.isNotEmpty
            ? calendarRepository.search(query).then((searchEvents) {
                List<SearchUiModel> result = [];
                int? tempYear;
                DateTime? tempDate;
                for (int index = 0; index < searchEvents.length; index++) {
                  var searchEvent = searchEvents[index];
                  if (tempYear != searchEvent.date.year) {
                    tempYear = searchEvent.date.year;
                    result.add(SearchUiModel(
                        itemType: ItemType.year, eventModel: searchEvent));
                  }

                  if (tempDate?.toIso8601String() !=
                      searchEvent.date.toIso8601String()) {
                    result.add(SearchUiModel(
                        itemType: ItemType.date, eventModel: searchEvent));
                  }
                  tempDate = searchEvent.date;
                  result.add(SearchUiModel(
                      itemType: ItemType.event, eventModel: searchEvent));
                }
                return result;
              })
            : Future.value([]));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    debugPrint('[TONY] buildSuggestions query: $query');
    return SizedBox.shrink();
  }
}
