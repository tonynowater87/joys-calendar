import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/addEvent/add_event_bloc.dart';

class AddEventPage extends StatefulWidget {
  AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  var currentDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) => AddEventBloc(context.read<LocalDatasource>()),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              width: screenWidth * 0.8,
              height: screenHeight / 2,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  border: const Border.fromBorderSide(BorderSide()),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Column(children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('手動新增日曆事件'),
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));
                      setState(() {
                        // TODO
                        currentDate = pickedDate ?? DateTime.now();
                      });
                    },
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label:
                        Text(currentDate.toIso8601String()), //TODO format date
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Scrollbar(
                    controller: _scrollController,
                    isAlwaysShown: true,
                    child: TextFormField(
                      cursorColor: Theme.of(context).focusColor,
                      initialValue: '',
                      minLines: 1,
                      maxLines: 4,
                      scrollController: _scrollController,
                      keyboardType: TextInputType.multiline,
                      onChanged: (text) {
                        // TODO
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.event_note),
                        labelText: '事件',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                          side: BorderSide()))),
                              onPressed: () {
                                // TODO
                                Navigator.pop(context);
                              },
                              child: const Text('取消'))),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide()))),
                            onPressed: () {
                              // TODO
                              Navigator.pop(context);
                            },
                            child: const Text('新增')),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          )),
    );
  }
}
