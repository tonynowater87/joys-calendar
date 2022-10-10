import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

class MyEventListItemPage extends StatelessWidget {
  MemoModel _memoModel;

  MyEventListItemPage(this._memoModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat(DateFormat.YEAR_MONTH_DAY).format(_memoModel.dateTime);
    final memo = _memoModel.memo;
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: Text('$date $memo')),
          const Divider()
        ],
      ),
    );
  }
}
