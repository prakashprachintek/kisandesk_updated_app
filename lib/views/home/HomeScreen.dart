import 'package:flutter/cupertino.dart';

import 'HomePage.dart';
import 'home_page2.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage(phoneNumber: '', userData: {},); // Redirecting to your existing home screen
  }
}