import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:joys_calendar/common/app_bloc_observer.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/firebase_options.dart';
import 'package:joys_calendar/repo/api/calendar_api_client.dart';
import 'package:joys_calendar/repo/api/logging_interceptor.dart';
import 'package:joys_calendar/repo/app_info_provider.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/backup/backup_repository_firebase.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy_impl.dart';
import 'package:joys_calendar/repo/constants.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/local/local_datasource_impl.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:joys_calendar/repo/shared_preference_provider_impl.dart';
import 'package:joys_calendar/view/home/my_home_page.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_cubit.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_page.dart';
import 'package:joys_calendar/view/search_result/search_result_cubit.dart';
import 'package:joys_calendar/view/search_result/search_result_page.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_page.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await LocalDatasourceImpl.init();
  await initializeDateFormatting();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: "Joys-Calendar",options: DefaultFirebaseOptions.currentPlatform);

  print('[Tony] App Launched, kDebugMode=$kDebugMode');
  if (kDebugMode) {
    // https://firebase.google.com/docs/emulator-suite/install_and_configure?authuser=0
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    LoggingInterceptor.debug = false;
    Bloc.observer = AppBlocObserver();
  } else {
    LoggingInterceptor.debug = false;
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
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
        RepositoryProvider<SharedPreferenceProvider>(
            create: (BuildContext context) {
          return SharedPreferenceProviderImpl(_prefs);
        }),
        RepositoryProvider<CalendarEventRepository>(
            create: (BuildContext context) {
          var dio = Dio(BaseOptions(
              connectTimeout: 1000 * 10, receiveTimeout: 1000 * 10));
          dio.interceptors.add(LoggingInterceptor());
          const calendarApiKey = String.fromEnvironment('ApiKey');
          if (calendarApiKey.isEmpty) {
            throw AssertionError('ApiKey is not set');
          }
          return CalendarEventRepositoryImpl(
              CalendarApiClient(dio, baseUrl: apiBaseURL),
              context.read<SharedPreferenceProvider>(),
              context.read<LocalDatasource>(),
              calendarApiKey);
        }),
        RepositoryProvider<BackUpRepository>(
          lazy: false,
          create: (BuildContext context) {
            return FirebaseBackUpRepository(
                localDatasource: context.read<LocalDatasource>(),
                firebaseAuth: FirebaseAuth.instance,
                firebaseStorage: FirebaseStorage.instance,
                sharedPreferenceProvider:
                    context.read<SharedPreferenceProvider>());
          },
        ),
      ],
      child: MaterialApp(
          title: 'Joy\' Calendar',
          theme: JoysCalendarThemeData.lightThemeData,
          initialRoute: AppConstants.routeHome,
          localizationsDelegates: const [
            MonthYearPickerLocalizations.delegate
          ],
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
                child: const MyEventListPage()),
            AppConstants.routeSearchResult: (context) => BlocProvider(
                create: (context) =>
                    SearchResultCubit(context.read<CalendarEventRepository>()),
                child: const SearchResultPage())
          }),
    );
  }
}
