import 'package:flutter/material.dart';

import '../redundant files/login_page.dart';


class LanguageSelectionPage extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  LanguageSelectionPage({required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildLanguageButton('ಕನ್ನಡ', () {
                    onLocaleChange(Locale('kn'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
                  buildLanguageButton('English', () {
                    onLocaleChange(Locale('en'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
                ],
              ),
              SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildLanguageButton('हिंदी', () {
                    onLocaleChange(Locale('hi'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
                  buildLanguageButton('मराठी', () {
                    onLocaleChange(Locale('mr'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguageButton(String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 50,
      width: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          side: BorderSide(color: Color(0xFF00AD83)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF00AD83),
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
