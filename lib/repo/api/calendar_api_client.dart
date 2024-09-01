import 'package:dio/dio.dart';
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
  @GET("v3/calendars/{countryCalendarEventPath}")
  Future<EventDto> getEvents(
      @Path() String countryCalendarEventPath, @Query("key") String apiKey, @Query("pageToken") String? nextPageToken);

  // https://www.googleapis.com/calendar/v3/calendars/zh-tw.taiwan%23holiday%40group.v.calendar.google.com/events?key=AIzaSyDJLKS03Kg7SvgBXBiyON2GqrXObN0Cq3U&timeMin=2024-09-01T00:00:00%2B08:00&timeMax=2025-09-01T00:00:00%2B08:00
  @GET("v3/calendars/{countryCalendarEventPath}")
  Future<EventDto> getEventsByTimeRange(
      @Path() String countryCalendarEventPath,
      @Query("key") String apiKey,
      @Query("timeMin") String timeMin,
      @Query("timeMax") String timeMax);
}
