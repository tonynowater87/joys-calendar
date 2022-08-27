import 'package:dio/dio.dart';
import 'package:joys_calendar/repo/constants.dart';
import 'package:joys_calendar/repo/model/event_dto/event_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'calendar_api_client.g.dart';

@RestApi()
abstract class CalendarApiClient {
  factory CalendarApiClient(Dio dio, {String baseUrl}) = _CalendarApiClient;

  // v3/calendars/en.uk%23holiday%40group.v.calendar.google.com/events?key=xxxxxx
  // v3/calendars/en.usa%23holiday%40group.v.calendar.google.com/events?key=xxxxxx
  // v3/calendars/zh-tw.taiwan%23holiday%40group.v.calendar.google.com/events?key=xxxxxx
  // v3/calendars/ja.japanese.taiwan%23holiday%40group.v.calendar.google.com/events?key=xxxxxx
  @GET("v3/calendars/{countryCalendarEventPath}/key=$apiKey")
  Future<EventDto> getEvents(@Path() String countryCalendarEventPath);
}
