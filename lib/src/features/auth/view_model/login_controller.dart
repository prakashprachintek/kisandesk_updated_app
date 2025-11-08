import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mainproject1/views/auth/OTPVerificationScreen.dart';
import '../../../shared/presentation/widgets/flutter_inappwebview.dart';
import '../repository/auth_repository.dart';
import '../view/signup_bottom_sheet.dart';
import '../../../core/constant/api_constants.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final AuthRepository _repo;
  LoginController(this._repo);


  var isLoading = false.obs;
  var isPhoneValid = false.obs;
  String? phoneError;

  @override
  void onInit() {
    super.onInit();
    phoneController.clear();
    phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    final phone = phoneController.text.trim();
    final regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(phone)) {
      phoneError = tr("Please enter a valid phone number");
      isPhoneValid.value = false;
    } else if (RegExp(r'^(\d)\1{9}$').hasMatch(phone)) {
      phoneError = tr("Invalid phone number. Try a different number.");
      isPhoneValid.value = false;
    } else {
      phoneError = null;
      isPhoneValid.value = true;
    }
  }

  Future<void> verifyPhoneNumber(BuildContext context) async {
    final phone = phoneController.text.trim();

    if (!isPhoneValid.value) {
      Get.snackbar("Error", phoneError ?? tr("Invalid phone number"));
      return;
    }

    isLoading.value = true;
    try {
      final data = await _repo.generateOtp(phone);
      if (data["status"] == "success") {
        Get.to(() => OTPVerificationScreen(phoneNumber: phone));
      } else if (data["status"] == "failed") {
        Get.bottomSheet(
          SignupBottomSheet(phone: phone),
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        );
      } else {
        Get.snackbar("Error", data["message"] ?? "Unknown error");
      }
    } catch (e) {
      Get.snackbar("Error", tr("Network error. Try again."));
    } finally {
      isLoading.value = false;
    }
  }

  void openTerms() {
    Get.to(() => const AppWebView(
      url: ApiConstants.termsAndConditionURL,
      title: "Terms & Condition",
    ));
  }

  void openPrivacyPolicy() {
    Get.to(() => const AppWebView(
      url: ApiConstants.privacyPolicyURL,
      title: "Privacy Policy",
    ));
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
