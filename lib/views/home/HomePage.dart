import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String phoneNumber;
  final Map<String, dynamic> userData;

  const HomePage({Key? key, required this.phoneNumber, required this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Color(0xFF1B5E20),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Home!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (phoneNumber.isNotEmpty) Text("Phone: $phoneNumber"),
            if (userData.isNotEmpty) Text("UserData: $userData"),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String phoneNumber;
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.phoneNumber, required this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomePage(phoneNumber: phoneNumber, userData: userData);
  }
}
