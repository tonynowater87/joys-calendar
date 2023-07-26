import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      child: BlocBuilder<AddEventBloc, AddEventState>(
        builder: (context, state) {
          final addEventState = state;
          final String titleText =
              addEventState.status == AddEventStatus.edit ? "編輯記事" : "新增記事";

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

          final dateText = Text(
              DateFormat(DateFormat.YEAR_MONTH_DAY, AppConstants.defaultLocale)
                  .format(state.memoModel.dateTime));

          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            insetPadding: const EdgeInsets.all(16.0),
            actionsAlignment: MainAxisAlignment.center,
            title: Row(
              children: [
                Text(titleText),
                const Spacer(),
                dateText,
                const Spacer(),
                InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: addEventState.memoModel.dateTime,
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
                    child: const Icon(Icons.edit_calendar_outlined))
              ],
            ),
            actions: [
              OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              OutlinedButton.icon(
                icon: addEventState.status == AddEventStatus.add
                    ? const Icon(Icons.add)
                    : const Icon(Icons.check),
                label: addEventState.status == AddEventStatus.add
                    ? const Text('新增')
                    : const Text('更新'),
                onPressed: () async {
                  final result = await context.read<AddEventBloc>().saveEvent();
                  if (!mounted || !result) {
                    return;
                  }
                  Navigator.pop(context, true);
                },
              )
            ],
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SizedBox(height: 8),
                Scrollbar(
                  controller: _scrollController,
                  isAlwaysShown: true,
                  child: TextField(
                    controller: _textEditingController,
                    cursorColor: Theme.of(context).focusColor,
                    minLines: 1,
                    maxLines: 8,
                    scrollController: _scrollController,
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {
                      context
                          .read<AddEventBloc>()
                          .add(UpdateMemoEvent(_textEditingController.text));
                    },
                    maxLength: 1000,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      hintText: '這天要記錄點什麼呢...？',
                      labelText: '我的記事',
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                  ),
                )
              ]),
            ),
          );
        },
      ),
    );
  }
}
