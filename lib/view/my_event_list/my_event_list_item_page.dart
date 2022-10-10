import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_ui_model.dart';

class MyEventListItemPage extends StatelessWidget {
  MyEventUIModel _model;
  int index;
  bool isDeleting;
  Function(int index, bool checked) onCheckCallback;

  MyEventListItemPage(
      this._model, this.index, this.onCheckCallback, this.isDeleting,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(DateFormat.YEAR_MONTH_DAY).format(_model.dateTime);
    final memo = _model.memo;
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$date $memo'),
                  Visibility(
                    visible: isDeleting,
                    /* below settings are for invisible  */
                    maintainSize: !isDeleting,
                    maintainAnimation: !isDeleting,
                    maintainState: !isDeleting,
                    child: Checkbox(
                        value: _model.isChecked,
                        onChanged: (isChecked) {
                          onCheckCallback.call(index, isChecked ?? false);
                        }),
                  )
                ],
              )),
          const Divider()
        ],
      ),
    );
  }
}
