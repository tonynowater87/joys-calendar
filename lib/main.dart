import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/my_home_page.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy_impl.dart';

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
          return CalendarEventRepositoryImpl(CalendarApiClient(Dio(BaseOptions(
              connectTimeout: 1000 * 10, receiveTimeout: 1000 * 10))));
        })
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}
