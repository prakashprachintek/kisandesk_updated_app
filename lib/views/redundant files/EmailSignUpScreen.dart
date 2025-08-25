import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';
import '../home/HomePage.dart';
import '../widgets/GradientAuthButton.dart';

class EmailSignUpScreen extends StatefulWidget {
  @override
  _EmailSignUpScreenState createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  Future<void> _signUp() async {
    final fullName = fullNameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (fullName.isEmpty || email.isEmpty || pass.isEmpty) {
      _showError("Please fill in full name, email, and password");
      return;
    }

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      if (userCred.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'fullName': fullName,
          'email': email,
          'createdAt': DateTime.now(),
        });
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            phoneNumber: '',
            userData: {
              "email": userCred.user?.email,
            },
          ),
        ),
      );
    } catch (e) {
      _showError("Sign-Up failed: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White AppBar
      appBar: AppBar(
        title: Text("Sign Up with Email",
            style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Lottie.asset("assets/animations/email.json",
                width: 180, height: 180),
            SizedBox(height: 20),
            Text(
              "Enter your name, valid email, & set a strong password",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: fullNameCtrl,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person, color: Colors.grey[700]),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 16),
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
              text: "Create Account",
              onTap: _signUp,
              textStyle: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
