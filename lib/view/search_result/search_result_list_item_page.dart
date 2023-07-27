import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/common/event_chip_view.dart';

class SearchResultListItemPage extends StatelessWidget {
  EventModel _model;
  int index;

  SearchResultListItemPage(this._model, this.index, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat(DateFormat.YEAR_MONTH_DAY, AppConstants.defaultLocale)
            .format(_model.date);
    final memo = _model.eventName;
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: _model.eventType.toEventColor()),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Text(
                                date,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: EventChipView(
                                  eventName: _model.eventType.toSettingName(),
                                  eventColor: _model.eventType.toEventColor()),
                            )
                          ],
                        )),
                    const SizedBox(height: 4),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            memo,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}
