import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart'; // Import the favorites provider
import 'Languageselection_page.dart';
import 'add_page.dart';
import 'profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('kn'), Locale('hi'), Locale('mr')],
      path: 'assets/lang', // Path to your JSON files
      fallbackLocale: Locale('en'),
      child: ChangeNotifierProvider(
        create: (context) => FavoritesProvider(), // Provide the FavoritesProvider
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: LanguageSelectionPage(
        onLocaleChange: (locale) {
          context.setLocale(locale);
        },
      ),
    );
  }
}
