/*
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../widgets/GradientAuthButton.dart';
import 'EmailSignInScreen.dart';
import 'EmailSignUpScreen.dart';

class EmailAuthSelectionScreen extends StatelessWidget {
  const EmailAuthSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White background
      appBar: AppBar(
        title: Text("Email / Password Auth", style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Lottie.asset("assets/animations/email.json", width: 180, height: 180),
            SizedBox(height: 20),
            Text(
              "Sign in or create an account with email",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            GradientAuthButton(
              text: "Sign In with Email",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EmailSignInScreen()));
              },
            ),
            SizedBox(height: 20),
            GradientAuthButton(
              text: "Sign Up (Register) with Email",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EmailSignUpScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/