import 'package:flutter/material.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_ui_model.dart';

class MyEventListItemPage extends StatelessWidget {
  final MyEventUIModel _model;
  int index;
  bool isDeleting;
  Function(int index, bool checked) onCheckCallback;

  MyEventListItemPage(
      this._model, this.index, this.onCheckCallback, this.isDeleting,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memo = _model.memo;
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        memo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )),
              ),
              Visibility(
                visible: isDeleting && _model.memo.isNotEmpty,
                /* below settings are for invisible  */
                maintainSize: !isDeleting,
                maintainAnimation: !isDeleting,
                maintainState: !isDeleting,
                child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    value: _model.isChecked,
                    onChanged: (isChecked) {
                      onCheckCallback.call(index, isChecked ?? false);
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }
}
