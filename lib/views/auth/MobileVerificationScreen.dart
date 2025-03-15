import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';
import '../home/HomePage.dart';
import '../home/HomeScreen.dart';
import '../widgets/GradientAuthButton.dart';
import 'OTPVerificationScreen.dart';

class MobileVerificationScreen extends StatefulWidget {
  @override
  _MobileVerificationScreenState createState() => _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
  final TextEditingController phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isValid10Digit(String phone) {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(phone);
  }

  Future<void> verifyPhoneNumber() async {
    final digitsOnly = phoneController.text.trim();
    if (!isValid10Digit(digitsOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid phone number. Enter 10 digits.")),
      );
      return;
    }
    final phoneNumber = "+91$digitsOnly";

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(),
          ));
        } catch (e) {
          print("Auto sign-in failed: $e");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification failed: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Auto retrieval timed out: $verificationId");
      },
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mobile Verification", style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 16),
            Lottie.asset("assets/animations/phone.json", width: 180, height: 180),
            SizedBox(height: 20),

            Text(
              "Enter Your Phone Number",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            SizedBox(height: 12),
            Text(
              "We'll send an OTP to verify your number (+91)",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "10-digit number",
                prefixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 24),

            GradientAuthButton(
              text: "Send OTP",
              onTap: verifyPhoneNumber,
            ),
            Spacer(),

            Text("Need Help?", style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
