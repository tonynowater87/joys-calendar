import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'search_result_state.dart';

class SearchResultCubit extends Cubit<SearchResultState> {
  SearchResultCubit() : super(SearchResultInitial());
}
