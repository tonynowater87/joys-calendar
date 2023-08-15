import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

abstract class AnalyticsHelper {
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters});
}

class AnalyticsHelperImpl extends AnalyticsHelper {
  @override
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
    if (parameters == null) {
      await FirebaseAnalytics.instance.logEvent(name: name).then((value) {
        debugPrint('[Tony] logEvent: $name');
      }).onError((error, stackTrace) {
        debugPrint('[Tony] logEvent: $name, error: $error');
      });
    } else {
      await FirebaseAnalytics.instance
          .logEvent(name: name, parameters: parameters)
          .then((value) {
        debugPrint('[Tony] logEvent: $name, parameters: $parameters');
      }).onError((error, stackTrace) {
        debugPrint(
            '[Tony] logEvent: $name, parameters: $parameters, error: $error');
      });
    }
  }
}
