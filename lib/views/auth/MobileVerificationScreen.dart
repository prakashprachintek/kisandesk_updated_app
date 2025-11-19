import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mainproject1/src/core/constant/api_constants.dart';
import 'package:mainproject1/src/core/style/colors.dart';
import 'package:mainproject1/src/features/auth/view/signup_bottom_sheet.dart';
import 'package:mainproject1/src/shared/presentation/widgets/flutter_inappwebview.dart';
import 'package:mainproject1/views/services/AppAssets.dart';
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
  String? phoneError;

  bool isValid10Digit(String phone) {
    // Check for 10 digits, starting with 6, 7, 8, or 9
    final regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(phone)) {
      phoneError = tr("Please enter a valid phone number");
      return false;
    }
    // Check for repetitive numbers (e.g., 1111111111, 0000000000)
    if (RegExp(r'^(\d)\1{9}$').hasMatch(phone)) {
      phoneError = tr("Invalid phone number. Try a different number.");
      return false;
    }
    phoneError = null;
    return true;
  }

  Future<void> verifyPhoneNumber() async {
    final phone = phoneController.text.trim();

    if (!isValid10Digit(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneError ?? tr("Invalid phone number"))),
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
            // await showSignupDialog(context, phone);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              builder: (_) => SignupBottomSheet(phone: phone),
            );
          } catch (e) {
            print("Signup dialog error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr("Something went wrong. Try again."))),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(tr("Error: ${data["message"] ?? "Unknown error"}"))),
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
  void initState() {
    super.initState();
    phoneController.addListener(() {
      final phone = phoneController.text.trim();
      print("Phone input: $phone, Valid: ${isValid10Digit(phone)}");
      setState(() {
        isPhoneValid = isValid10Digit(phone);
        if (isPhoneValid) {
          FocusScope.of(context).unfocus();
        }
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
                Lottie.asset(AppAssets.animPhone,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  tr("Enter Your Phone Number"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  tr("We'll send an OTP to verify your number (+91)"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                    errorText: phoneController.text.isNotEmpty && !isPhoneValid
                        ? phoneError
                        : null,
                    suffixIcon: isPhoneValid
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                  ),
                ),
                SizedBox(height: 24),
                GradientAuthButton(
                  text: isLoading ? tr("Checking...") : tr("Send OTP"),
                  onTap: isLoading || !isPhoneValid
                      ? null
                      : () async {
                          await verifyPhoneNumber();
                        },
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  opacity: isLoading || !isPhoneValid ? 0.5 : 1.0,
                ),
                SizedBox(height: 5),
                // Terms and Conditions text
                Text.rich(
                  TextSpan(
                    text: "By continuing, you agree to our ",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style:  TextStyle(
                          color: AppColors.buttonPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _openTerms,
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(
                          color: AppColors.buttonPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openPrivacyPolicy();
                          },
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final String termsUrl = "https://yourdomain.com/terms";

  Future<void> _openTerms() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppWebView(
          url: ApiConstants.termsAndConditionURL,
          title: "Terms & Condition",
        ),
      ),
    );

  }

  Future<void> _openPrivacyPolicy() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppWebView(
          url:ApiConstants.privacyPolicyURL,
          title: "Privacy Policy",
        ),
      ),
    );

  }

}