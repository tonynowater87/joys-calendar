import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/add_event/add_event_bloc.dart';

class AddEventPage extends StatefulWidget {
  dynamic? memoModelKey;

  AddEventPage({Key? key, this.memoModelKey}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController =
      TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider<AddEventBloc>(
      create: (context) {
        var addEventBloc = AddEventBloc(context.read<LocalDatasource>());
        if (widget.memoModelKey != null) {
          addEventBloc.add(EditDateTimeEvent(widget.memoModelKey));
        } else {
          addEventBloc.add(AddDateTimeEvent());
        }
        return addEventBloc;
      },
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
                  final addEventState = state;
                  if (addEventState.status == AddEventStatus.edit) {
                    if (_textEditingController.text.isEmpty) {
                      _textEditingController.text = addEventState.memoModel.memo;
                    } else {
                      _textEditingController.text = _textEditingController.text;
                    }
                    _textEditingController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _textEditingController.text.length));
                  } else if (addEventState.status == AddEventStatus.add &&
                      _textEditingController.text.isEmpty) {
                    _textEditingController.text = "";
                  }
                  return SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: addEventState.status == AddEventStatus.add
                            ? Text('新增')
                            : Text('編輯'),
                      ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // TODO locale for DatePicker
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
                          label: Text(DateFormat(DateFormat.YEAR_MONTH_DAY,
                                  AppConstants.defaultLocale)
                              .format(state.memoModel.dateTime)), // Locale
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Scrollbar(
                          controller: _scrollController,
                          isAlwaysShown: true,
                          child: TextField(
                            controller: _textEditingController,
                            cursorColor: Theme.of(context).focusColor,
                            minLines: 1,
                            maxLines: 4,
                            scrollController: _scrollController,
                            keyboardType: TextInputType.multiline,
                            onChanged: (text) {
                              context.read<AddEventBloc>().add(
                                  UpdateMemoEvent(_textEditingController.text));
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
                                    await context
                                        .read<AddEventBloc>()
                                        .saveEvent();
                                    if (!mounted) {
                                      return;
                                    }
                                    Navigator.pop(context, true);
                                  },
                                  child: addEventState.status == AddEventStatus.add
                                      ? Text('新增')
                                      : Text('更新')),
                            )
                          ],
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
          )),
    );
  }
}
