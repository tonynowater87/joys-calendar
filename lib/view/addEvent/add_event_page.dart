import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddEventPage extends StatefulWidget {
  AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  var currentDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: screenWidth * 0.8,
            height: screenHeight / 2,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                border: const Border.fromBorderSide(BorderSide()),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Column(children: <Widget>[
              const Text('Add Event'),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100));
                    setState(() {
                      // TODO
                      currentDate = pickedDate ?? DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: Text(currentDate.toIso8601String()),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Scrollbar(
                  controller: _scrollController,
                  isAlwaysShown: true,
                  child: TextFormField(
                    cursorColor: Theme.of(context).focusColor,
                    initialValue: '',
                    minLines: 1,
                    maxLines: 4,
                    scrollController: _scrollController,
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {
                      // TODO
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
                            onPressed: () {},
                            child: const Text('Cancel'))),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: BorderSide()))),
                          onPressed: () {},
                          child: const Text('Add')),
                    )
                  ],
                ),
              ),
            ]),
          ),
        ));
  }
}
