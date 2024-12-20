import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/common/app_bloc_observer.dart';
import 'package:joys_calendar/common/configs/colors.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/themes/theme_data.dart';
import 'package:joys_calendar/common/utils/notification_helper.dart';
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
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/local_notification_provider_impl.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:joys_calendar/repo/shared_preference_provider_impl.dart';
import 'package:joys_calendar/view/date_calculator/date_calculator_cubit.dart';
import 'package:joys_calendar/view/date_calculator/date_calculator_page.dart';
import 'package:joys_calendar/view/home/my_home_page.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_cubit.dart';
import 'package:joys_calendar/view/my_event_list/my_event_list_page.dart';
import 'package:joys_calendar/view/search_result/search_result_cubit.dart';
import 'package:joys_calendar/view/search_result/search_result_page.dart';
import 'package:joys_calendar/view/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  await LocalDatasourceImpl.init();

  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
      name: "Joys-Calendar", options: DefaultFirebaseOptions.currentPlatform);

  FirebaseStorage.instance
    ..setMaxOperationRetryTime(const Duration(seconds: 10))
    ..setMaxDownloadRetryTime(const Duration(seconds: 10))
    ..setMaxDownloadRetryTime(const Duration(seconds: 10));

  debugPrint('[Tony] App Launched, kDebugMode=$kDebugMode');
  if (kDebugMode) {
    FirebaseAnalytics.instance
        .setAnalyticsCollectionEnabled(false); // disable in debug mode
    // https://firebase.google.com/docs/emulator-suite/install_and_configure?authuser=0
    // fixme, currently can't connect emulator via real device (Android)
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    LoggingInterceptor.debug = false;
    Bloc.observer = AppBlocObserver();
  } else {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
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
  MobileAds.instance.initialize().then((value) => {
    MobileAds.instance..setAppMuted(true)..setAppVolume(0.05)
  });
  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  SharedPreferences _prefs;

  MyApp(this._prefs, {super.key}) {}

  @override
  Widget build(BuildContext context) {
    // 設定狀態欄顏色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.nord14,
    ));
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppInfoProvider>(create: (BuildContext context) {
          return AppInfoProvider();
        }),
        RepositoryProvider<SharedPreferenceProvider>(
            create: (BuildContext context) {
          return SharedPreferenceProviderImpl(_prefs);
        }),
        RepositoryProvider<LocalNotificationProvider>(
            create: (BuildContext context) {
              return LocalNotificationProviderImpl(
                  sharedPreferenceProvider:
                      context.read<SharedPreferenceProvider>());
            },
            lazy: false),
        RepositoryProvider<LocalDatasource>(create: (BuildContext context) {
          return LocalDatasourceImpl();
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
              calendarApiKey,
              context.read<LocalNotificationProvider>());
        }),
        RepositoryProvider<BackUpRepository>(
          lazy: false,
          create: (BuildContext context) {
            return FirebaseBackUpRepository(
                localDatasource: context.read<LocalDatasource>(),
                firebaseAuth: FirebaseAuth.instance,
                firebaseStorage: FirebaseStorage.instance,
                sharedPreferenceProvider:
                    context.read<SharedPreferenceProvider>(),
                localNotificationProvider:
                    context.read<LocalNotificationProvider>(),
                calendarEventRepository:
                    context.read<CalendarEventRepository>());
          },
        ),
        RepositoryProvider<AnalyticsHelper>(create: (BuildContext context) {
          return AnalyticsHelperImpl();
        }),
        RepositoryProvider<NotificationHelper>(create: (BuildContext context) {
          return NotificationHelper(
              calendarEventRepository: context.read<CalendarEventRepository>(),
              localNotificationProvider:
                  context.read<LocalNotificationProvider>());
        }),
      ],
      child: MaterialApp(
          title: 'Joy\' Calendar',
          theme: JoysCalendarThemeData.lightThemeData,
          initialRoute: AppConstants.routeHome,
          debugShowCheckedModeBanner: false,
          locale: window.locale,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.2);
            return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                child: child!);
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant")
          ],
          routes: <String, WidgetBuilder>{
            AppConstants.routeHome: (context) =>
                const MyHomePage(title: 'Joy\' Calendar'),
            AppConstants.routeSettings: (context) => const SettingsPage(),
            AppConstants.routeMyEvent: (context) => BlocProvider(
                create: (context) => MyEventListCubit(
                    context.read<LocalDatasource>(),
                    context.read<SharedPreferenceProvider>(),
                    context.read<LocalNotificationProvider>()),
                child: const MyEventListPage()),
            AppConstants.routeSearchResult: (context) => BlocProvider(
                create: (context) =>
                    SearchResultCubit(context.read<CalendarEventRepository>()),
                child: const SearchResultPage()),
            AppConstants.routeDateCalculator: (context) => BlocProvider(
              create: (context) => DateCalculatorCubit(DateTime.now()),
                  child: const DateCalculatorPage(),
                ),
          }),
    );
  }
}
