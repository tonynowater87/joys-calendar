import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:joys_calendar/common/app_bloc_observer.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/api/logging_interceptor.dart';
import 'package:joys_calendar/repo/app_info_provider.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy_impl.dart';
import 'package:joys_calendar/repo/constants.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/local_datasource_impl.dart';
import 'package:joys_calendar/repo/shared_preference_provider_impl.dart';
import 'package:joys_calendar/view/add_event/add_event_bloc.dart';
import 'package:joys_calendar/view/home/my_home_page.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_cubit.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_page.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await LocalDatasourceImpl.init();
  await initializeDateFormatting();
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

  MyApp(this._prefs, {super.key}) {}

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppInfoProvider>(create: (BuildContext context) {
          return AppInfoProvider();
        }),
        RepositoryProvider<LocalDatasource>(create: (BuildContext context) {
          return LocalDatasourceImpl();
        }),
        RepositoryProvider<CalendarEventRepository>(
            create: (BuildContext context) {
          var dio = Dio(BaseOptions(
              connectTimeout: 1000 * 10, receiveTimeout: 1000 * 10));
          dio.interceptors.add(LoggingInterceptor());
          var sharedPreferenceProvider = SharedPreferenceProviderImpl(_prefs);
          const calendarApiKey = String.fromEnvironment('ApiKey');
          if (calendarApiKey.isEmpty) {
            throw AssertionError('ApiKey is not set');
          }
          return CalendarEventRepositoryImpl(
              CalendarApiClient(dio, baseUrl: apiBaseURL),
              sharedPreferenceProvider,
              context.read<LocalDatasource>(), calendarApiKey);
        }),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AddEventBloc>(
              create: (context) =>
                  AddEventBloc(context.read<LocalDatasource>()))
        ],
        child: MaterialApp(
            title: 'Joy\' Calendar',
            theme: JoysCalendarThemeData.lightThemeData,
            initialRoute: AppConstants.routeHome,
            routes: <String, WidgetBuilder>{
              AppConstants.routeHome: (context) =>
                  const MyHomePage(title: 'Joy\' Calendar'),
              AppConstants.routeSettings: (context) => BlocProvider(
                    create: (context) =>
                        SettingsBloc(context.read<CalendarEventRepository>()),
                    child: const SettingsPage(),
                  ),
              AppConstants.routeMyEvent: (context) => BlocProvider(
                  create: (context) =>
                      MyEventListCubit(context.read<LocalDatasource>()),
                  child: const MyEventListPage())
            }),
      ),
    );
  }
}
