import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:joys_calendar/repo/local/model/memo_model.dart';

enum MyEventListStatus { loading, loaded }

@immutable
class MyEventListState extends Equatable {
  List<MemoModel> myEventList = [];
  MyEventListStatus myEventListStatus;

  MyEventListState({
    required this.myEventList,
    required this.myEventListStatus,
  });

  MyEventListState copyWith({
    List<MemoModel>? myEventList,
    MyEventListStatus? myEventListStatus,
  }) {
    return MyEventListState(
      myEventList: myEventList ?? this.myEventList,
      myEventListStatus: myEventListStatus ?? this.myEventListStatus,
    );
  }

  @override
  List<Object?> get props => [myEventListStatus, myEventList];
}
