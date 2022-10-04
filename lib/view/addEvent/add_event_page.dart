import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/addEvent/add_event_bloc.dart';

class AddEventPage extends StatefulWidget {

  AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
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
              child: BlocBuilder<AddEventBloc, AddEventState>(
                builder: (context, state) {
                  return Column(children: <Widget>[
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
                          if (!mounted) {
                            return;
                          }
                          if (pickedDate != null) {
                            context
                                .read<AddEventBloc>()
                                .add(UpdateDateTimeEvent(pickedDate));
                          }
                        },
                        icon: const Icon(Icons.edit_calendar_outlined),
                        label: Text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(state.memoModel.dateTime)), // Locale
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
                            context.read<AddEventBloc>().add(UpdateMemoEvent(text));
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
                                onPressed: () async {
                                  await context.read<AddEventBloc>().saveEvent();
                                  if (!mounted) {
                                    return;
                                  }
                                  Navigator.pop(context, true);
                                },
                                child: const Text('新增')),
                          )
                        ],
                      ),
                    ),
                  ]);
                },
              ),
            ),
          )),
    );
  }
}
