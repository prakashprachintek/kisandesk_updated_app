import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticRepository {

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

   void analyticsCall() async {
    await analytics.logEvent(
      name: 'login',
      parameters: {
        'status': 'opened',
      },
    );
  }
}
