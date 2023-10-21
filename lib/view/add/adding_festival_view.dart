import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/view/add/adding_event_bloc.dart';
import 'package:joys_calendar/view/add/adding_event_page.dart';

class AddingFestivalView extends StatefulWidget {
  OnClickDatePicker onClickDatePicker;

  AddingFestivalView({Key? key, required this.onClickDatePicker})
      : super(key: key);

  @override
  State<AddingFestivalView> createState() => _AddingFestivalViewState();
}

class _AddingFestivalViewState extends State<AddingFestivalView> {
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

    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      InkWell(
        onTap: () {
          debugPrint('[Tony] context = $context');
          widget.onClickDatePicker(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            calendar,
            dateText,
            const SizedBox(width: 5),
            const Icon(Icons.edit_calendar_outlined),
          ],
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _textEditingController,
        cursorColor: Theme.of(context).focusColor,
        minLines: 1,
        maxLines: 1,
        scrollController: _scrollController,
        keyboardType: TextInputType.multiline,
        onChanged: (text) {
          //TODO
        },
        maxLength: 30,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: InputDecoration(
          hintText: '',
          labelText: '我的節日',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(),
          ),
        ),
      ),
      Row(
        children: [
          const Icon(Icons.info_outline, size: 10),
          const SizedBox(width: 4),
          Text('節日是每年都有的日子', style: Theme.of(context).textTheme.overline),
        ],
      )
    ]);
  }
}
