import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mainproject1/main.dart';
import 'package:mainproject1/views/auth/AuthSelectionScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mainproject1/views/splashs/SplashScreen.dart';

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
                    SizedBox(
                      height: 30,
                    ),
                    Image.asset(
                      'assets/New_logo.png',
                      height: 200,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Select a Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal[800],
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            offset: Offset(0.5, 0.5),
                            blurRadius: 1.5,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    //buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLocale = const Locale('en');
                              });
                              context.setLocale(const Locale('en'));
                              Get.updateLocale(_selectedLocale!);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                color: _selectedLocale == const Locale('en')
                                    ? Color(0xFF1B5E20)
                                        .withOpacity(0.8) // Highlighted
                                    : Colors.green.withOpacity(0.1), // Default
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'English',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _selectedLocale == const Locale('en')
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                  if (_selectedLocale ==
                                      const Locale('en')) ...[
                                    SizedBox(width: 8),
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLocale = const Locale('kn');
                              });
                              context.setLocale(const Locale('kn'));
                              Get.updateLocale(_selectedLocale!);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                color: _selectedLocale == const Locale('kn')
                                    ? Color(0xFF1B5E20).withOpacity(0.8)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ಕನ್ನಡ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _selectedLocale == const Locale('kn')
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                  if (_selectedLocale ==
                                      const Locale('kn')) ...[
                                    SizedBox(width: 8),
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),

                    //next button

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
                            ? Color(0xFF1B5E20)
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
