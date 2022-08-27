import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/api/logging_interceptor.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy_impl.dart';
import 'package:joys_calendar/repo/constants.dart';
import 'package:joys_calendar/view/home/my_home_page.dart';
import 'package:joys_calendar/view/settings/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CalendarEventRepository>(
            create: (BuildContext context) {
          var dio = Dio(BaseOptions(
              connectTimeout: 1000 * 10, receiveTimeout: 1000 * 10));
          dio.interceptors.add(LoggingInterceptor());
          return CalendarEventRepositoryImpl(
              CalendarApiClient(dio, baseUrl: apiBaseURL));
        })
      ],
      child: MaterialApp(
          title: 'Joy\' Calendar',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: "/home",
          routes: <String, WidgetBuilder>{
            '/home': (context) => const MyHomePage(title: 'Joy\' Calendar'),
            '/settings': (context) => const SettingsPage()
          }),
    );
  }
}
