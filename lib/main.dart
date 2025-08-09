import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';

import 'views/other/welcome.dart';
import 'views/home/HomePage.dart';
import 'views/services/user_session.dart';
import 'views/services/background_message.dart';
import 'views/services/push_notification_service.dart';
import 'views/services/notification_data.dart';
import 'views/services/notification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.loadUserFromPrefs();

  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await PushNotificationService.initializeLocalNotifications();
  await PushNotificationService.initializeFCM();

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('kn'),
        Locale('hi'),
        Locale('mr')
      ],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushNotificationService.navigatorContext =
          MyApp.navigatorKey.currentContext;
    });
    _setupNotificationTapHandler();
  }

  void _setupNotificationTapHandler() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      _navigateToNotificationPage(initialMessage.data);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        _navigateToNotificationPage(message.data);
      }
    });
  }

  void _navigateToNotificationPage(Map<String, dynamic> data) {
    final notificationData = NotificationData.fromMap(data);
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => NotificationPage(notificationData: notificationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisan Desk'.tr(),
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: UserSession.user != null ? HomePage() : KisanDeskScreen(),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primaryColor: Color(0xFF1B5E20),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
          .copyWith(secondary: Color(0xFFFFA000)),
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFF1B5E20),
          minimumSize: Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF1B5E20), width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
    );
  }
}