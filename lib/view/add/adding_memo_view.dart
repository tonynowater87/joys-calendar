import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/view/add/adding_event_bloc.dart';
import 'package:joys_calendar/view/add/adding_event_page.dart';

class AddingMemoView extends StatefulWidget {
  OnClickDatePicker onClickDatePicker;

  AddingMemoView({Key? key, required this.onClickDatePicker}) : super(key: key);

  @override
  State<AddingMemoView> createState() => _AddingMemoViewState();
}

class _AddingMemoViewState extends State<AddingMemoView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController =
      TextEditingController(text: "");

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AddingEventBloc>().state;
    final Text calendar;
    if (state.isLunar) {
      calendar = const Text('農曆');
    } else {
      calendar = const Text('國曆');
    }
    final dateText = Text(
        state.isLunar
            ? state.dateModel.toLunar().toString()
            : state.dateModel.toSolar().toString(),
        style: Theme.of(context).textTheme.caption);
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        InkWell(
          onTap: () {
            widget.onClickDatePicker(context);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              calendar,
              dateText,
              const SizedBox(width: 5),
              const Icon(Icons.edit_calendar_outlined)
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textEditingController,
          cursorColor: Theme.of(context).focusColor,
          minLines: 3,
          maxLines: 10,
          scrollController: _scrollController,
          keyboardType: TextInputType.multiline,
          onChanged: (text) {
            //TODO
          },
          maxLength: 1000,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: InputDecoration(
            hintText: '',
            labelText: '我的記事',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(),
            ),
          ),
        )
      ]),
    );
  }
}
