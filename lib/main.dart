import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/common/app_bloc_observer.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/api/logging_interceptor.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy_impl.dart';
import 'package:joys_calendar/repo/constants.dart';
import 'package:joys_calendar/repo/local/local_datasource_impl.dart';
import 'package:joys_calendar/repo/shared_preference_provider_impl.dart';
import 'package:joys_calendar/view/home/my_home_page.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await LocalDatasourceImpl.init();
  if (kDebugMode) {
    LoggingInterceptor.debug = false;
    Bloc.observer = AppBlocObserver();
  } else {
    LoggingInterceptor.debug = false;
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  SharedPreferences _prefs;

  MyApp(this._prefs, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CalendarEventRepository>(
            create: (BuildContext context) {
          var dio = Dio(BaseOptions(
              connectTimeout: 1000 * 10, receiveTimeout: 1000 * 10));
          dio.interceptors.add(LoggingInterceptor());
          var sharedPreferenceProvider = SharedPreferenceProviderImpl(_prefs);
          return CalendarEventRepositoryImpl(
              CalendarApiClient(dio, baseUrl: apiBaseURL),
              sharedPreferenceProvider);
        })
      ],
      child: MaterialApp(
          title: 'Joy\' Calendar',
          theme: JoysCalendarThemeData.lightThemeData,
          initialRoute: "/home",
          routes: <String, WidgetBuilder>{
            '/home': (context) => const MyHomePage(title: 'Joy\' Calendar'),
            '/settings': (context) => BlocProvider(
                  create: (context) =>
                      SettingsBloc(context.read<CalendarEventRepository>()),
                  child: const SettingsPage(),
                )
          }),
    );
  }
}
