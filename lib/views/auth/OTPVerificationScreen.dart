import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';
import '../home/HomePage.dart';
import '../widgets/GradientAuthButton.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyOTP() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP cannot be empty")));
      return;
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(phoneNumber: widget.phoneNumber, userData: {})),
      );
    } catch (e) {
      print("OTP Verification failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP Verification failed: $e")));
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification", style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 16),
            Lottie.asset("assets/animations/lock.json", width: 180, height: 180),
            SizedBox(height: 20),

            Text(
              "Enter OTP",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            SizedBox(height: 12),
            Text(
              "OTP sent to: ${widget.phoneNumber}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "6-digit OTP",
                prefixIcon: Icon(Icons.password, color: Colors.grey[700]),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 24),

            GradientAuthButton(
              text: "Verify OTP",
              onTap: verifyOTP,
            ),
            Spacer(),

            Text("Wrong number? Go back", style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
