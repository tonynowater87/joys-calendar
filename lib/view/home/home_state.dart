part of 'home_cubit.dart';

enum HomeStatus { loading, success, title }

class HomeState extends Equatable {
  final List<CalendarEvent> events;
  final HomeStatus status;

  const HomeState._(
      {this.events = const <CalendarEvent>[], this.status = HomeStatus.loading});

  const HomeState.loading() : this._();

  const HomeState.success(List<CalendarEvent> events)
      : this._(status: HomeStatus.success, events: events);

  @override
  List<Object?> get props => [status, events];
}
