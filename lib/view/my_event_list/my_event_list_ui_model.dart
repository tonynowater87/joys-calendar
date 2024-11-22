import 'package:equatable/equatable.dart';

class MyEventUIModel extends Equatable {
  int key;
  String memo;
  DateTime dateTime;
  bool isChecked;
  bool showLunar;

  @override
  List<Object?> get props => [key, memo, dateTime, isChecked, showLunar];

  MyEventUIModel({
    required this.key,
    required this.memo,
    required this.dateTime,
    required this.isChecked,
    required this.showLunar,
  });

  MyEventUIModel copyWith(bool isChecked) {
    return MyEventUIModel(key: key, memo: memo, dateTime: dateTime, isChecked: isChecked, showLunar: showLunar);
  }
}
