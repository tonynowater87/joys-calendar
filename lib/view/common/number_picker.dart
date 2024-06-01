import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  final String title;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const NumberPicker({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  _NumberPickerState createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late int currentValue;
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
    textEditingController = TextEditingController(text: '$currentValue');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: currentValue > widget.minValue
              ? () {
                  setState(() {
                    currentValue--;
                    textEditingController.text = '$currentValue';
                    widget.onChanged(currentValue);
                  });
                }
              : null,
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: textEditingController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null &&
                  intValue >= widget.minValue &&
                  intValue <= widget.maxValue) {
                setState(() {
                  currentValue = intValue;
                  widget.onChanged(currentValue);
                });
              }
            },
            onSubmitted: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null &&
                  intValue >= widget.minValue &&
                  intValue <= widget.maxValue) {
                setState(() {
                  currentValue = intValue;
                  widget.onChanged(currentValue);
                });
              } else {
                textEditingController.text = '$currentValue';
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: currentValue < widget.maxValue
              ? () {
                  setState(() {
                    currentValue++;
                    textEditingController.text = '$currentValue';
                    widget.onChanged(currentValue);
                  });
                }
              : null,
        ),
      ],
    );
  }
}
