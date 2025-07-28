import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import './views/other/welcome.dart';

import 'views/splashs/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized(); // IMPORTANT!

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('kn'),
        Locale('hi'),
        Locale('mr')
      ],
      path: 'assets/lang', // your JSON files are here
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisan Desk',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),

      // 👇 VERY IMPORTANT for EasyLocalization to work
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      home: SplashScreen(),
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
