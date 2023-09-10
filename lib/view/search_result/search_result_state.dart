part of 'search_result_cubit.dart';

enum SearchStatus { loading, hasResult, empty }

class SearchResultState extends Equatable {
  final List<SearchUiModel> events;
  final SearchStatus status;

  const SearchResultState._(
      {this.events = const <SearchUiModel>[], this.status = SearchStatus.loading});

  const SearchResultState.loading() : this._();

  const SearchResultState.hasResult(List<SearchUiModel> events)
      : this._(status: SearchStatus.hasResult, events: events);

  const SearchResultState.empty() : this._(status: SearchStatus.empty);

  @override
  List<Object?> get props => [status, events];
}
