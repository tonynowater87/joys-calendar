class AppConstants {
  // app route
  static const String routeHome = '/home';
  static const String routeSettings = '/settings';
  static const String routeMyEvent = '/my_event';
  static const String routeSearchResult = '/search_result';
  static const String routeDateCalculator = '/date_calculator';
  static const String defaultLocale = 'zh_TW';

  // memo date format
  static const String memoDateFormat = 'yyyy/MM/dd';

  // notify date format
  static const String notifyDateFormat = 'MM/dd(E)';

  // ad-mob id
  static const String INTERSTITIAL_ANDROID_ID = String.fromEnvironment(
      "INTERSTITIAL-ANDROID-ID",
      defaultValue: "ca-app-pub-3940256099942544/8691691433");
  static const String INTERSTITIAL_IOS_ID = String.fromEnvironment("INTERSTITIAL-IOS-ID",
      defaultValue: "ca-app-pub-3940256099942544/8691691433");

  // constant for chinese lunar notify logic
  static const String LUNAR_CHINESE_YEAR = "農曆";
  static const String FOR_LUNAR_CHINESE_YEAR_WORK_DAY = "補班";
}
