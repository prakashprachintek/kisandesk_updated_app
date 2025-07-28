import 'package:flutter/material.dart';
import 'package:mainproject1/main.dart';
import 'package:mainproject1/views/auth/AuthSelectionScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mainproject1/views/splashs/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('kn')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: KisanDeskScreen(),
    ),
  );
}

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This class is still problematic and not used in the main function's runApp.
    // It's recommended to remove or correct it if it's intended for use.
    return MaterialApp(
      home: Welcome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KisanDeskScreen extends StatefulWidget {
  @override
  _KisanDeskScreenState createState() => _KisanDeskScreenState();
}

class _KisanDeskScreenState extends State<KisanDeskScreen> {
  // Variable to hold the currently selected locale
  Locale? _selectedLocale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Logo.jpeg',
                      height: 100,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Welcome To Kisan Desk',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Select a Language',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedLocale = const Locale('en');
                              });
                              context.setLocale(const Locale('en'));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedLocale ==
                                      const Locale('en')
                                  ? Color(0xFF4CAF50) // Highlight when selected
                                  : Colors.white,
                              foregroundColor:
                                  _selectedLocale == const Locale('en')
                                      ? Colors.white // Highlight when selected
                                      : Colors.black,
                              side: BorderSide(
                                color: Color(0xFF4CAF50), // Always green border
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('English'),
                                if (_selectedLocale == const Locale('en')) ...[
                                  SizedBox(width: 8),
                                  Icon(Icons.check_circle,
                                      size: 20), // Tick mark for English
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedLocale = const Locale('kn');
                              });
                              context.setLocale(const Locale('kn'));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedLocale ==
                                      const Locale('kn')
                                  ? Color(0xFF4CAF50) // Highlight when selected
                                  : Colors.white,
                              foregroundColor:
                                  _selectedLocale == const Locale('kn')
                                      ? Colors.white // Highlight when selected
                                      : Colors.black,
                              side: BorderSide(
                                color: Color(0xFF4CAF50), // Always green border
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('ಕನ್ನಡ'),
                                if (_selectedLocale == const Locale('kn')) ...[
                                  SizedBox(width: 8),
                                  Icon(Icons.check_circle,
                                      size: 20), // Tick mark for Kannada
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: _selectedLocale != null
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SplashScreen()),
                              );
                            }
                          : null,
                      child: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedLocale != null
                            ? Color(0xFF4CAF50)
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
