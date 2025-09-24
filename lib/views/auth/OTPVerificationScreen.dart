import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/auth/MobileVerificationScreen.dart';
import 'dart:convert';
import '../services/user_session.dart';
import '../services/api_config.dart';
import '../home/HomePage.dart';
import '../widgets/GradientAuthButton.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart'; // Only for app signature

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
  bool isResendLoading = false;
  String? errorMessage;
  bool isOtpValid = false;
  int secondsRemaining = 30;
  bool resendEnabled = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    _logAppSignature(); // Log signature for backend
  }

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

  Future<void> _logAppSignature() async {
    try {
      String? appSignature = await SmsAutoFill().getAppSignature;
      print("App Signature: $appSignature (Share this with SMS provider for auto-fill)");
    } catch (e) {
      print("Error getting app signature: $e");
    }
  }

  Future<void> resendOTP() async {
    setState(() {
      isResendLoading = true;
      otpController.clear();
      errorMessage = null;
      isOtpValid = false;
    });

    final url = Uri.parse("${KD.api}/admin/generate_otp");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNumber": widget.phoneNumber}),
      );

      final data = jsonDecode(response.body);
      print("Resend OTP API Response: $data");

      if (response.statusCode == 200 && data["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("OTP resent successfully"))),
        );
        startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? tr("Failed to resend OTP")),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Network error. Try again."))),
      );
    } finally {
      setState(() => isResendLoading = false);
    }
  }

  Future<void> verifyOTP() async {
    final otp = otpController.text.trim();

    if (otp.length != 4 || !RegExp(r'^\d{4}$').hasMatch(otp)) {
      setState(() {
        errorMessage = tr("Please enter a valid OTP");
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse("${KD.api}/admin/verify_otp");
    String? token = await FirebaseMessaging.instance.getToken();
    print("⭐⭐FCM Token: $token");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"phoneNumber": widget.phoneNumber, "otp": otp, "token": token}),
      );

      final data = jsonDecode(response.body);
      print("🔓🔓API2 Response: $data");

      if (response.statusCode == 200) {
        if (data["status"] == "success") {
          UserSession.setUser(data["result"]);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        } else if (data["status"] == "failed") {
          setState(() {
            errorMessage = data["message"] == "Invalid OTP"
                ? tr("Please enter a valid OTP")
                : data["message"] ?? tr("OTP verification failed");
          });
        }
      } else {
        setState(() {
          errorMessage = tr("Server error. Try again.");
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = tr("Network error. Try again.");
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          tr("OTP Verification"),
          style: TextStyle(color: Colors.grey[700]),
        ),
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      PinCodeTextField(
                        appContext: context,
                        length: 4,
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        showCursor: false,
                        textStyle: TextStyle(fontSize: 20),
                        animationType: AnimationType.scale,
                        cursorColor: Colors.green.shade800,
                        onChanged: (value) {
                          print("onChanged: value=$value, length=${value.length}");
                          setState(() {
                            isOtpValid = value.trim().length == 4 &&
                                RegExp(r'^\d{4}$').hasMatch(value.trim());
                            if (errorMessage != null) {
                              errorMessage = null;
                            }
                          });
                        },
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 55,
                          fieldWidth: 75,
                          activeFillColor: Colors.green.shade50,
                          selectedFillColor: Colors.green.shade100,
                          inactiveFillColor: Colors.grey.shade200,
                          activeColor: Colors.green,
                          selectedColor: Colors.green.shade800,
                          inactiveColor: Colors.white,
                        ),
                        animationDuration: const Duration(milliseconds: 250),
                        enableActiveFill: true,
                      ),
                      const SizedBox(height: 20),
                      GradientAuthButton(
                        text: isLoading ? tr("Verifying...") : tr("Verify OTP"),
                        onTap: isLoading || !isOtpValid ? null : verifyOTP,
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        opacity: isLoading || !isOtpValid ? 0.5 : 1.0,
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 32, 90, 40),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            resendEnabled
                                ? TextButton(
                                    onPressed: isResendLoading ? null : resendOTP,
                                    child: Text(
                                      isResendLoading
                                          ? tr("Resending...")
                                          : tr("Resend OTP"),
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "${tr('Resend in')} 00:${secondsRemaining.toString().padLeft(2, '0')}",
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