import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/view/add/adding_event_bloc.dart';
import 'package:joys_calendar/view/add/adding_event_type.dart';
import 'package:joys_calendar/view/add/adding_festival_view.dart';
import 'package:joys_calendar/view/add/adding_memo_view.dart';
import 'package:joys_calendar/view/common/button_style.dart';
import 'package:joys_calendar/view/common/date_picker/date_model.dart';
import 'package:joys_calendar/view/common/date_picker/default_date_picker_dialog.dart';

typedef OnClickDatePicker = void Function(BuildContext context);

class AddingEventPage extends StatefulWidget {
  final DateTime dateTime;

  const AddingEventPage({Key? key, required this.dateTime}) : super(key: key);

  @override
  State<AddingEventPage> createState() => _AddingEventPageState();
}

class _AddingEventPageState extends State<AddingEventPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: BlocProvider(
          create: (context) => AddingEventBloc(DateTime.now()),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500, minHeight: 200),
              child: BlocBuilder<AddingEventBloc, AddingEventState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoSegmentedControl(
                            padding: const EdgeInsets.all(0),
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            unselectedColor:
                                Theme.of(context).colorScheme.surface,
                            children: const {
                              AddingEventType.memo: Text("新增記事"),
                              AddingEventType.festival: Text("新增節日")
                            },
                            groupValue: state.eventType,
                            onValueChanged: (value) {
                              context
                                  .read<AddingEventBloc>()
                                  .add(AddingEventChangeType(value));
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                            width: double.infinity,
                            child: state.eventType == AddingEventType.festival
                                ? AddingFestivalView(
                                    onClickDatePicker: onClickDatePicker)
                                : AddingMemoView(
                                    onClickDatePicker: onClickDatePicker)),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 8.0, right: 20.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                  style: appOutlineButtonStyle(),
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('取消'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                style: appOutlineButtonStyle(),
                                icon: const Icon(Icons.add),
                                label: const Text('新增'),
                                onPressed: () async {
                                  //TODO
                                  Navigator.pop(context, true);
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              )),
        ));
  }

  void onClickDatePicker(BuildContext context) async {
    var state = context.read<AddingEventBloc>().state;
    DateModel? result = await showDialog(
        context: context,
        builder: (context) {
          return state.isLunar
              ? DefaultDatePickerDialog.fromLunarDate(
                  state.dateModel.year,
                  state.dateModel.month,
                  state.dateModel.day,
                )
              : DefaultDatePickerDialog.fromDate(
                  state.dateModel.year,
                  state.dateModel.month,
                  state.dateModel.day,
                );
        });
    if (!mounted) {
      return;
    }
    if (result != null) {
      context
          .read<AddingEventBloc>()
          .add(AddingEventChangeDate(result, result.isLunar));
    }
  }
}
