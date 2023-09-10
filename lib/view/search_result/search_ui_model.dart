import 'package:equatable/equatable.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

enum ItemType { year, date, event }

class SearchUiModel extends Equatable {
  ItemType itemType;
  EventModel eventModel;

  SearchUiModel({
    required this.itemType,
    required this.eventModel,
  });

  @override
  List<Object?> get props => [itemType, eventModel];
}
