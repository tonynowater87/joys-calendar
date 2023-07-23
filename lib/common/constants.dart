class AppConstants {
  // app route
  static const String routeHome = '/home';
  static const String routeSettings = '/settings';
  static const String routeMyEvent = '/my_event';
  static const String routeSearchResult = '/search_result';
  static const String defaultLocale = 'zh_TW';

  // ad-mob id
  static const String INTERSTITIAL_ANDROID_ID = String.fromEnvironment(
      "INTERSTITIAL-ANDROID-ID",
      defaultValue: "ca-app-pub-3940256099942544/8691691433");
  static const String INTERSTITIAL_IOS_ID = String.fromEnvironment("INTERSTITIAL-IOS-ID",
      defaultValue: "ca-app-pub-3940256099942544/8691691433");
}
