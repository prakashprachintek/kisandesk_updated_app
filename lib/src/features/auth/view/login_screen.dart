import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mainproject1/views/widgets/GradientAuthButton.dart';
import '../../../core/style/colors.dart';
import '../view_model/login_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.find<LoginController>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  init() async {
    controller.onInit();
    await analytics.logEvent(
      name: 'login',
      parameters: {
        'status': 'opened',
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    init();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Mobile Verification"),
            style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Lottie.asset("assets/animations/phone.json",
                  width: 180, height: 180),
              const SizedBox(height: 20),
               Text(
                tr("Enter Your Phone Number"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 12),
              Text(
                tr("We'll send an OTP to verify your number (+91)"),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              //  Phone input
              Obx(() => TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    onChanged: (value) {
                      // Remove any non-digit characters
                      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                      if (digitsOnly.length == 10 &&
                          controller.isPhoneValid.value &&
                          !controller.isLoading.value) {
                        //Dismiss Keyboard
                        FocusScope.of(context).unfocus();

                        // Auto-trigger OTP send
                        Future.microtask(() {
                          controller.verifyPhoneNumber(context);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: tr("10-digit number"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor.withAlpha(110),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      errorText: controller.isPhoneValid.value
                          ? null
                          : controller.phoneError,
                      suffixIcon: controller.isPhoneValid.value
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                    ),
                  )),

              const SizedBox(height: 24),

              //  Button
              Obx(() => GradientAuthButton(
                    text:
                        controller.isLoading.value ? tr("Checking...") : tr("Send OTP"),
                    onTap: controller.isLoading.value ||
                            !controller.isPhoneValid.value
                        ? null
                        : () => controller.verifyPhoneNumber(context),
                    opacity: controller.isLoading.value ||
                            !controller.isPhoneValid.value
                        ? 0.5
                        : 1.0,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(height: 5),

              //  Terms
              Text.rich(
                TextSpan(
                  text: "By continuing, you agree to our ",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: "Terms & Conditions",
                      style: const TextStyle(
                        color: AppColors.buttonPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = controller.openTerms,
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
                        ..onTap = controller.openPrivacyPolicy,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
