import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_cubit.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('我的日曆列表'),
      ),
      body: BlocBuilder<MyEventListCubit, MyEventListState>(
        builder: (context, state) {
          if (state.myEventListStatus == MyEventListStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
                itemCount: state.myEventList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                        state.myEventList[index].dateTime.toIso8601String()),
                    trailing: Text(state.myEventList[index].memo),
                  );
                });
          }
        },
      ),
    );
  }
}
