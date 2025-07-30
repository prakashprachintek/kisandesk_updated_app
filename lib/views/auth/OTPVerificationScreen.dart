import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/auth/MobileVerificationScreen.dart';
import 'dart:convert';
import '../other/user_session.dart';
import '../widgets/api_config.dart';
import '../../main.dart';
import '../home/HomePage.dart';
import '../widgets/GradientAuthButton.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

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

  int secondsRemaining = 30;
  bool resendEnabled = false;
  late Timer timer;

  void startTimer() {
    setState(() {
      secondsRemaining = 30;
      resendEnabled = false;
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        setState(() {
          resendEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer(); // start countdown on screen load
  }

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
          //storing data for later user
          UserSession.setUser(data["result"]);
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
    timer.cancel();
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Lottie.asset("assets/animations/lock.json",
                          width: 180, height: 180),
                      const SizedBox(height: 20),
                      Text(
                        tr("Enter OTP"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr("OTP sent to: ${widget.phoneNumber}"),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        showCursor: false,
                        textStyle: TextStyle(fontSize: 20),
                        animationType: AnimationType.scale,
                        cursorColor: Colors.green.shade800,
                        onChanged: (value) {},
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 55,
                          fieldWidth: 45,
                          activeFillColor: Colors.green.shade50,
                          selectedFillColor: Colors.green.shade100,
                          inactiveFillColor: Colors.grey.shade200,
                          activeColor: Colors.green,
                          selectedColor: Colors.green.shade800,
                          inactiveColor: Colors.grey.shade400,
                        ),
                        animationDuration: const Duration(milliseconds: 250),
                        enableActiveFill: true,
                      ),
                      // SizedBox(height: 2),

                      const SizedBox(height: 2),
                      GradientAuthButton(
                        text: isLoading ? tr("Verifying...") : tr("Verify OTP"),
                        onTap: isLoading ? null : verifyOTP,
                        textStyle: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 0),

                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MobileVerificationScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                tr("Wrong number? Go back"),
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 32, 90, 40),
                                  fontSize: 14,
                                  // decoration: TextDecoration.underline,
                                ),
                              ),
                            ),

                            resendEnabled
                                ? TextButton(
                                    onPressed: () {
                                      startTimer(); // restart the timer
                                    },
                                    child: Text(
                                      "Resend OTP",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Resend in 00:${secondsRemaining.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14),
                                  ),
                            
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
