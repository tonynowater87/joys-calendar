part of 'home_cubit.dart';

enum HomeStatus { loading, success, title, failure }

class HomeState extends Equatable {
  final List<CalendarEvent> events;
  final HomeStatus status;
  final String title;

  const HomeState._(
      {this.events = const <CalendarEvent>[], this.status = HomeStatus.loading, this.title = ""});

  const HomeState.loading() : this._();

  const HomeState.success(List<CalendarEvent> events)
      : this._(status: HomeStatus.success, events: events);

  const HomeState.title(List<CalendarEvent> events, String title)
      : this._(status: HomeStatus.success, events: events, title: title);

  const HomeState.failure() : this._(status: HomeStatus.failure);

  @override
  List<Object?> get props => [status, events, title];
}
