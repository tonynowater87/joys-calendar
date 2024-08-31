import 'package:flutter/material.dart';

class EventChipView extends StatelessWidget {
  final String eventName;
  final Color eventColor;

  const EventChipView(
      {Key? key, required this.eventName, required this.eventColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          border: Border.all(color: eventColor),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Text(
        eventName,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
