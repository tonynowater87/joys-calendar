part of 'adding_event_bloc.dart';

@immutable
class AddingEventState implements Equatable {
  final DateModel dateModel;
  final AddingEventType eventType;
  final String content;
  final bool isLunar;

  AddingEventState(this.dateModel, this.eventType, this.content, this.isLunar);

  AddingEventState copyWith(
      {DateModel? dateTime,
      AddingEventType? eventType,
      String? content,
      bool? isLunar}) {
    return AddingEventState(
        dateTime ?? this.dateModel,
        eventType ?? this.eventType,
        content ?? this.content,
        isLunar ?? this.isLunar);
  }

  @override
  String toString() {
    return 'AddingEventState{dateTime: $dateModel, eventType: $eventType, content: $content, isLunar: $isLunar}';
  }

  @override
  List<Object?> get props => [dateModel, eventType, content, isLunar];

  @override
  bool? get stringify => true;
}
