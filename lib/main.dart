import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';

import 'views/other/welcome.dart';
import 'views/home/HomePage.dart';
import 'views/services/user_session.dart';
import 'views/notification module/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load stored user session before app starts
  await UserSession.loadUserFromPrefs();

  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  // Set Firebase background message handler (push received when app is killed/background)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Local Notifications (for showing in foreground & tap handling)
  await PushNotificationService.initializeLocalNotifications();

  // Initialize Push Notification Service (handles foreground, background, killed taps)
  await PushNotificationService.initialize();

  // Run App
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('kn'),
        Locale('hi'),
        Locale('mr'),
      ],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // Global navigator key to allow navigation from notification handlers
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisan Desk'.tr(),
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      navigatorKey: MyApp.navigatorKey, // Needed for navigation from service
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
      appBarTheme: AppBarTheme(
        backgroundColor: Color.fromARGB(255, 29, 108, 92), // Your AppBar color
        foregroundColor: Colors.white, // Optional: for title/icon color
        elevation: 4, // Optional: adjust elevation if needed
      ),
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