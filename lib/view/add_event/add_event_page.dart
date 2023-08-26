import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/analytics/analytics_events.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/utils/dialog.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/add_event/add_event_bloc.dart';
import 'package:joys_calendar/view/common/button_style.dart';

class AddEventPage extends StatefulWidget {
  dynamic? memoModelKey;
  DateTime? dateTime;

  AddEventPage({Key? key, this.memoModelKey, this.dateTime}) : super(key: key);

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
    final analyticsHelper = context.read<AnalyticsHelper>();
    return BlocProvider<AddEventBloc>(
      create: (context) {
        var addEventBloc = AddEventBloc(context.read<LocalDatasource>());
        if (widget.memoModelKey != null) {
          addEventBloc.add(EditDateTimeEvent(widget.memoModelKey));
        } else {
          if (widget.dateTime == null) {
            addEventBloc.add(AddDateTimeEvent());
          } else {
            addEventBloc.add(AddDateTimeEvent());
            addEventBloc.add(ChangeDateTimeEvent(widget.dateTime!));
          }
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
              DateFormat(
                      DateFormat.YEAR_MONTH_DAY, AppConstants.defaultLocale)
                  .format(state.memoModel.dateTime),
              style: Theme.of(context).textTheme.caption);

          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            actionsAlignment: MainAxisAlignment.end,
            actionsPadding: const EdgeInsets.fromLTRB(0.0, 10.0, 24.0, 20.0),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(titleText, style: Theme.of(context).textTheme.headline4),
                InkWell(
                  onTap: () async {
                    if (addEventState.status == AddEventStatus.add) {
                      analyticsHelper
                          .logEvent(name: event_select_date, parameters: {
                        event_select_date_params_position_name:
                            event_select_date_params_position.add.toString(),
                      });
                    } else if (addEventState.status == AddEventStatus.edit) {
                      analyticsHelper
                          .logEvent(name: event_select_date, parameters: {
                        event_select_date_params_position_name:
                            event_select_date_params_position.edit.toString(),
                      });
                    }
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
                          .add(ChangeDateTimeEvent(pickedDate));
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      dateText,
                      const SizedBox(width: 5),
                      const Icon(Icons.edit_calendar_outlined)
                    ],
                  ),
                )
              ],
            ),
            actions: [
              Visibility(
                visible: addEventState.status == AddEventStatus.edit,
                child: OutlinedButton.icon(
                  style: appOutlineButtonStyle(),
                  icon: const Icon(Icons.delete),
                  label: const Text('刪除'),
                  onPressed: () {
                    if (!mounted) {
                      return;
                    }
                    DialogUtils.showAlertDialog(
                        title: "確定要刪除這筆記事嗎？",
                        onConfirmCallback: () async {
                          await context.read<AddEventBloc>().delete();
                          Navigator.pop(context, true);
                        },
                        context: context);
                  },
                ),
              ),
              OutlinedButton.icon(
                  style: appOutlineButtonStyle(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              OutlinedButton.icon(
                style: appOutlineButtonStyle(),
                icon: addEventState.status == AddEventStatus.add
                    ? const Icon(Icons.add)
                    : const Icon(Icons.check),
                label: addEventState.status == AddEventStatus.add
                    ? const Text('新增')
                    : const Text('更新'),
                onPressed: () async {
                  final result =
                      await context.read<AddEventBloc>().saveEvent();
                  if (!mounted || !result) {
                    return;
                  }
                  Navigator.pop(context, true);
                },
              ),
            ],
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textEditingController,
                    cursorColor: Theme.of(context).focusColor,
                    minLines: 3,
                    maxLines: 10,
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
                  )
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
