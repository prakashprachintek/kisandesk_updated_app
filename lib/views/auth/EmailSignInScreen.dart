import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';
import '../home/HomePage.dart';
import '../widgets/GradientAuthButton.dart';

class EmailSignInScreen extends StatefulWidget {
  @override
  _EmailSignInScreenState createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  Future<void> _signIn() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _showError("Please fill in both email and password");
      return;
    }
    try {
      final userCred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            phoneNumber: '',
            userData: {"email": userCred.user?.email},
          ),
        ),
      );

    } catch (e) {
      _showError("Sign-In failed: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White AppBar
      appBar: AppBar(
        title: Text("Sign In with Email", style: TextStyle(color: Colors.grey[700])),
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
              "Enter your email and password",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email, color: Colors.grey[700]),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock, color: Colors.grey[700]),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 24),

            GradientAuthButton(
              text: "Sign In",
              onTap: _signIn,
            ),
          ],
        ),
      ),
    );
  }
}
