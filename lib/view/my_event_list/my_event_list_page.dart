import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/add_event/add_event_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<MyEventListCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              ? Text('刪除(${myEventState.checkedCount})')
              : const Text('我的日曆列表'),
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
                      await context.read<MyEventListCubit>().delete();
                    }
                  }),
            )
          ],
          elevation: 0.5,
        ),
        body: ListView.custom(
          padding: const EdgeInsets.only(top: 10),
          childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return InkWell(
                  onTap: () async {
                    if (isDeleting || myEventState.myEventList[index].memo.isEmpty) {
                      return;
                    }
                    bool? isUpdated = await showDialog(
                        context: context,
                        builder: (context) => AddEventPage(memoModelKey: myEventState.myEventList[index].key));
                    if (!mounted) {
                      return;
                    }
                    if (isUpdated == true) {
                      context.read<MyEventListCubit>().load();
                    }
                  },
                  child: MyEventListItemPage(
                      myEventState.myEventList[index], index,
                      (index, isChecked) {
                    context
                        .read<MyEventListCubit>()
                        .updateChecked(index, isChecked);
                  }, isDeleting, key: ValueKey<String>(index.toString())),
                );
              },
              childCount: myEventState.myEventList.length,
              findChildIndexCallback: (Key key) {
                final ValueKey<String> valueKey = key as ValueKey<String>;
                return int.parse(valueKey.value);
              }),
        ));
  }
}
