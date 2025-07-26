import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/api_config.dart';
import '../../main.dart';
import '../home/HomePage.dart';
import '../widgets/GradientAuthButton.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOTP() async {
    final otp = otpController.text.trim();

    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Enter a valid 6-digit OTP"))),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("${KD.api}/admin/verify_otp");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNumber": widget.phoneNumber,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);
      print("API2 Response: $data");

      if (response.statusCode == 200) {
        if (data["status"] == "success") {
          // OTP correct → Navigate to Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        } else if (data["status"] == tr("failed")) {
          // OTP incorrect or not generated → Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(data["message"] ?? tr("OTP verification failed"))),
          );

          // If OTP was never generated, force a retry
          if (data["message"] == tr("Please generate OTP")) {
            // Navigator.pop(context); // Go back to phone input
            // will work when the changes in the backedn will be made
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("Server error. Try again."))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Network error. Try again."))),
      );
    } finally {
      setState(() => isLoading = false);
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
        automaticallyImplyLeading: false,
        title: Text(tr("OTP Verification"),
            style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 16),
            Lottie.asset("assets/animations/lock.json",
                width: 180, height: 180),
            SizedBox(height: 20),
            Text(
              tr("Enter OTP"),
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20)),
            ),
            SizedBox(height: 12),
            Text(
              tr("OTP sent to: ${widget.phoneNumber}"),
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: tr("6-digit OTP"),
                counterText: "",
                prefixIcon: Icon(Icons.password, color: Colors.grey[700]),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 24),
            GradientAuthButton(
              text: isLoading ? tr("Verifying...") : tr("Verify OTP"),
              onTap: isLoading ? null : verifyOTP,
              textStyle: TextStyle(fontSize: 14),
            ),
            Spacer(),
            Text(tr("Wrong number? Go back"),
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
