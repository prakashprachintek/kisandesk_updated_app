import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:mainproject1/src/core/style/colors.dart';
import 'package:mainproject1/src/features/auth/view_model/login_controller.dart';
import 'package:mainproject1/src/shared/presentation/widgets/custom_text_field.dart';
import 'package:mainproject1/views/auth/OTPVerificationScreen.dart';
import 'package:mainproject1/views/services/api_config.dart';

class SignupBottomSheet extends StatefulWidget {
  final String phone;
  const SignupBottomSheet({Key? key, required this.phone}) : super(key: key);

  @override
  State<SignupBottomSheet> createState() => _SignupBottomSheetState();
}

class _SignupBottomSheetState extends State<SignupBottomSheet> {
  // final controller = Get.put(LoginController());
  final controller = Get.find<LoginController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedVillage;
  bool hasSubmitted = false;
  bool isSubmitting = false;

  List<String> districts = [];
  List<String> taluks = [];
  List<String> villagesList = [];

  Map<String, List<dynamic>> talukasMap = {};
  Map<String, List<dynamic>> villagesMap = {};

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final String jsonString =
    await rootBundle.loadString('assets/loadLocation_data.json');
    final Map<String, dynamic> locationData = json.decode(jsonString);

    talukasMap = Map.from(locationData['talukas']);
    villagesMap = Map.from(locationData['villages']);

    talukasMap.forEach((key, value) {
      value.sort((a, b) =>
          a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    });

    villagesMap.forEach((key, value) {
      value.sort((a, b) =>
          a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    });

    setState(() {
      districts =
      List<String>.from(locationData['districts']['Karnataka'] ?? []);
      districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });
  }

  Future<void> _submitForm() async {
    setState(() => hasSubmitted = true);

    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      try {
        final userInsertUrl = Uri.parse("${KD.api}/user/insert_user");
        final response = await http.post(
          userInsertUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phoneNumber": widget.phone,
            "fullName": _nameController.text.trim(),
            "district": selectedDistrict,
            "taluka": selectedTaluk,
            "village": selectedVillage,
            "pincode": _pincodeController.text.trim(),
            "state": "Karnataka",
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data["status"] == "success") {
          final generateOtpUrl = Uri.parse("${KD.api}/admin/generate_otp");
          final otpResponse = await http.post(
            generateOtpUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"phoneNumber": widget.phone}),
          );

          final otpData = jsonDecode(otpResponse.body);

          if (otpResponse.statusCode == 200 && otpData["status"] == "success") {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr("Sign Up Initiated Successfully"))),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OTPVerificationScreen(phoneNumber: widget.phone),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(otpData["message"] ?? tr("Failed to generate OTP")),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? tr("Registration failed")),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("Error: $e"))),
        );
      } finally {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75, //
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr("Sign Up"),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: tr("Mobile Number"),
                          readOnly: true,
                          controller: TextEditingController(text: widget.phone),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        // Full Name
                        CustomTextField(
                          controller: _nameController,
                          label: tr("Full Name"),
                          keyboardType: TextInputType.name,
                          hint: "Eg: Ram Kumar",
                          validator: (value) => value == null ||
                              value.trim().isEmpty
                              ? tr("Please enter your full name")
                              : null,
                          onChanged: (value) {
                            if (hasSubmitted) {
                              _formKey.currentState!.validate();
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // District
                        DropdownButtonFormField<String>(
                          value: selectedDistrict,
                          decoration: _dropdownDecoration(tr("District")),
                          hint: Text(tr("Select District"),style: TextStyle(color: Colors.black26),),
                          items: districts.map((district) {
                            return DropdownMenuItem(
                              value: district,
                              child: Text(district),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDistrict = value;
                              selectedTaluk = null;
                              selectedVillage = null;
                              taluks = value != null
                                  ? List<String>.from(talukasMap[value] ?? [])
                                  : [];
                              villagesList = [];
                            });
                          },
                          validator: (value) =>
                          value == null ? tr("Please select a district") : null,
                        ),
                        const SizedBox(height: 12),

                        // Taluk
                        if (selectedDistrict != null)...[
                          DropdownButtonFormField<String>(
                            value: selectedTaluk,
                            isExpanded: true,
                            decoration: _dropdownDecoration(tr("Taluk")),
                            hint: Text(tr("Select Taluk",),style: TextStyle(color: Colors.black26),),
                            items: taluks.map((taluk) {
                              return DropdownMenuItem<String>(
                                value: taluk,
                                child: Text(
                                  taluk,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTaluk = value;
                                selectedVillage = null;
                                villagesList = value != null
                                    ? List<String>.from(villagesMap[value] ?? [])
                                    : [];
                              });
                            },
                            validator: (value) =>
                            value == null ? tr("Please select a taluk") : null,
                          ),
                          const SizedBox(height: 12),
                        ],


                        // Village
                        if (selectedTaluk != null)...[
                          DropdownButtonFormField<String>(
                            value: selectedVillage,
                            isExpanded: true,
                            decoration: _dropdownDecoration(tr("Village")),
                            hint: Text(tr("Select Village"),style: TextStyle(color: Colors.black26),),

                            items: villagesList.map((village) {
                              return DropdownMenuItem<String>(
                                value: village,
                                child: Text(
                                  village,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedVillage = value;
                              });
                            },
                            validator: (value) =>
                            value == null ? tr("Please select a village") : null,
                          ),
                          const SizedBox(height: 12),
                        ],



                        // Pincode
                        CustomTextField(
                          controller: _pincodeController,
                          fieldType: TextFieldType.pinCode,
                          keyboardType: TextInputType.number,
                          label: tr("Pincode"),
                          hint: "Eg: 568038",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return tr("Please enter a pincode");
                            }
                            if (value.length != 6) {
                              return tr("Pincode must be 6 digits");
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 80), // extra space above button
                      ],
                    ),
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSubmitting ? null : _submitForm,
                          child: isSubmitting
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Text(tr("Submit")),
                        ),
                        //  Terms
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text.rich(
                            TextSpan(
                              text: "By continuing, you agree to our ",
                              style:
                              const TextStyle(fontSize: 13, color: Colors.black54),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
