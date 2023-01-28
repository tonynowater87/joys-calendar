import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/model/event_model.dart';

part 'search_result_state.dart';

class SearchResultCubit extends Cubit<SearchResultState> {
  CalendarEventRepository calendarRepository;

  SearchResultCubit(this.calendarRepository)
      : super(const SearchResultState.loading());

  Future<void> search(String keyword) async {
    emit(const SearchResultState.loading());
    final result = await calendarRepository.search(keyword);
    print('[Tony] search result size=${result.length}');
    if (result.isEmpty) {
      emit(const SearchResultState.empty());
    } else {
      emit(SearchResultState.hasResult(result));
    }
  }
}
