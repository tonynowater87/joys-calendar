import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              child: isDeleting
                  ? Center(child: Text('取消'))
                  : Icon(Icons.arrow_back),
              onTap: () {
                if (isDeleting) {
                  context.read<MyEventListCubit>().cancelDeleting();
                } else {
                  Navigator.of(context).pop();
                }
              }),

          title: isDeleting ? Text('刪除()') /*TODO*/: Text('我的日曆列表'),
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: InkWell(
                  child: isDeleting ? Icon(Icons.delete) : Icon(Icons.edit),
                  onTap: () {
                    if (!isDeleting) {
                      context.read<MyEventListCubit>().startDeleting();
                    } else {
                      context.read<MyEventListCubit>().delete();
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
                return MyEventListItemPage(myEventState.myEventList[index],
                    key: ValueKey<String>(index.toString()));
              },
              childCount: myEventState.myEventList.length,
              findChildIndexCallback: (Key key) {
                final ValueKey<String> valueKey = key as ValueKey<String>;
                return int.parse(valueKey.value);
              }),
        ));
  }
}
