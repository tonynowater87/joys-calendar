import 'package:flutter/material.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/common/event_chip_view.dart';

class SearchResultListItemPage extends StatelessWidget {
  EventModel _model;

  SearchResultListItemPage(this._model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memo = _model.eventName;
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: EventChipView(
              eventName: _model.eventType.toSettingName(),
              eventColor: _model.eventType.toEventColor()),
        ),
        Flexible(
          flex: 4,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 0, top: 4, bottom: 4),
            child: Text(
              memo,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        )
      ],
    );
  }
}
