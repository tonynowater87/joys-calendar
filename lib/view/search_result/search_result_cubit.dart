import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/view/search_result/search_ui_model.dart';

part 'search_result_state.dart';

class SearchResultCubit extends Cubit<SearchResultState> {
  CalendarEventRepository calendarRepository;

  SearchResultCubit(this.calendarRepository)
      : super(const SearchResultState.loading());

  Future<void> search(String keyword) async {
    emit(const SearchResultState.loading());
    final searchEvents = await calendarRepository.search(keyword);
    if (searchEvents.isEmpty) {
      emit(const SearchResultState.empty());
    } else {
      List<SearchUiModel> result = [];
      int? tempYear;
      DateTime? tempDate;
      for (int index = 0; index < searchEvents.length; index++) {
        var searchEvent = searchEvents[index];
        if (tempYear != searchEvent.date.year) {
          tempYear = searchEvent.date.year;
          result.add(
              SearchUiModel(itemType: ItemType.year, eventModel: searchEvent));
        }

        if (tempDate?.toIso8601String() != searchEvent.date.toIso8601String()) {
          result.add(
              SearchUiModel(itemType: ItemType.date, eventModel: searchEvent));
        }
        tempDate = searchEvent.date;
        result.add(
            SearchUiModel(itemType: ItemType.event, eventModel: searchEvent));
      }
      emit(SearchResultState.hasResult(result));
    }
  }
}
