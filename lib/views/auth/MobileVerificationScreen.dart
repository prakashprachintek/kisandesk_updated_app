import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_config.dart';
import '../widgets/GradientAuthButton.dart';
import 'OTPVerificationScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signupDialog.dart';

class MobileVerificationScreen extends StatefulWidget {
  @override
  _MobileVerificationScreenState createState() =>
      _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  bool isPhoneValid = false;

  bool isValid10Digit(String phone) {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(phone);
  }

  Future<void> verifyPhoneNumber() async {
    final phone = phoneController.text.trim();

    if (!isValid10Digit(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Invalid phone number. Enter 10 digits."))),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("${KD.api}/admin/generate_otp");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNumber": phone}),
      );

      final data = jsonDecode(response.body);
      print("API1 Response: $data");

      if (response.statusCode == 200) {
        if (data["status"] == "success") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(phoneNumber: phone),
            ),
          );
        } else if (data["status"] == "failed") {
          try {
            await showSignupDialog(context, phone);
          } catch (e) {
            print("Signup dialog error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Something went wrong. Try again.")),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${data["message"] ?? "Unknown error"}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error. Try again.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    phoneController.addListener(() {
      print(
          "Phone input: ${phoneController.text}, Valid: ${isValid10Digit(phoneController.text.trim())}");
      setState(() {
        isPhoneValid = isValid10Digit(phoneController.text.trim());
      });
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          tr("Mobile Verification"),
          style: TextStyle(color: Colors.grey[700]),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              children: [
                SizedBox(height: 16),
                Lottie.asset(
                  "assets/animations/phone.json",
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  tr("Enter Your Phone Number"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  tr("We'll send an OTP to verify your number (+91)"),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: tr("10-digit number"),
                    prefixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    /*
                    suffixIcon: isPhoneValid
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    errorText: phoneController.text.isNotEmpty && !isPhoneValid
                        ? tr("Enter 10 digits")
                        : null,
                        */
                  ),
                ),
                SizedBox(height: 24),
                GradientAuthButton(
                  text: isLoading ? tr("Checking...") : tr("Send OTP"),
                  onTap: isLoading || !isPhoneValid
                      ? null
                      : () async {
                          await verifyPhoneNumber(); // Wrap async call
                        },
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  opacity: isLoading || !isPhoneValid ? 0.5 : 1.0, // Visual feedback
                ),
                SizedBox(height: 16),
                Text(
                  tr("Need Help?"),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}