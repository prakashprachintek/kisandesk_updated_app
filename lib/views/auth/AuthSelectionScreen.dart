import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../widgets/AuthOptionCard.dart';
import 'EmailAuthSelectionScreen.dart';
import 'GoogleSignInHandler.dart';
import 'MobileVerificationScreen.dart';

BoxDecoration topGradient() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF1B5E20),
        Color(0xFF4CAF50),
        Color(0xFFFFD600),
      ],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Lottie.asset('assets/animations/login.json'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Welcome to Kisan Desk!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Choose your preferred sign-in method below",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),

                    AuthOptionCard(
                      lottieFile: 'assets/animations/phone.json',
                      title: "Mobile OTP",
                      subtitle: "Login with your phone number",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MobileVerificationScreen()));
                      },
                    ),
                    SizedBox(height: 20),
                    AuthOptionCard(
                      lottieFile: 'assets/animations/google.json',
                      title: "Google Account",
                      subtitle: "Use your Google account to sign in",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => GoogleSignInHandler()));
                      },
                    ),
                    SizedBox(height: 20),
                    AuthOptionCard(
                      lottieFile: 'assets/animations/email.json',
                      title: "Email & Password",
                      subtitle: "Sign in or register with your email",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EmailAuthSelectionScreen()));
                      },
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
