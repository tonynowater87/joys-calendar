import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/view/search_result/search_result_argument.dart';
import 'package:joys_calendar/view/search_result/search_result_cubit.dart';
import 'package:joys_calendar/view/search_result/search_result_list_item_page.dart';

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
    args = ModalRoute.of(context)!.settings.arguments as SearchResultArguments;
    SearchResultState searchResultState =
        context.watch<SearchResultCubit>().state;

    Widget body;

    if (searchResultState.status == SearchStatus.loading) {
      body = const CircularProgressIndicator();
    } else if (searchResultState.status == SearchStatus.empty) {
      body = const Text('查無資料');
    } else {
      body = ListView.custom(
        padding: const EdgeInsets.only(top: 10),
        childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return InkWell(
                child: SearchResultListItemPage(
                    searchResultState.events[index], index,
                    key: ValueKey<String>(index.toString())),
              );
            },
            childCount: searchResultState.events.length,
            findChildIndexCallback: (Key key) {
              final ValueKey<String> valueKey = key as ValueKey<String>;
              return int.parse(valueKey.value);
            }),
      );
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('搜尋 [ ${args?.keyword} ]'),
        ),
        body: Center(child: body));
  }
}
