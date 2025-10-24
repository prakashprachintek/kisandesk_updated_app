import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/api_config.dart';
import 'OTPVerificationScreen.dart';

Future<Map<String, dynamic>> loadLocationJson() async {
  final String jsonString = await rootBundle.loadString('assets/loadLocation_data.json');
  return json.decode(jsonString);
}

Future<void> showSignupDialog(BuildContext context, String phone) async {
  print("Dialog loaded");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedVillage;
  bool hasSubmitted = false; // Track submission attempt
  bool isSubmitting = false;

  List<String> districts = [];
  List<String> taluks = [];
  List<String> villagesList = [];

  Map<String, dynamic> locationData = await loadLocationJson();

  // Copy and sort the maps
  Map<String, List<dynamic>> talukasMap = Map.from(locationData['talukas']);
  Map<String, List<dynamic>> villagesMap = Map.from(locationData['villages']);

  talukasMap.forEach((key, value) {
    value.sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  });

  villagesMap.forEach((key, value) {
    value.sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  });

  districts = List<String>.from(locationData['districts']['Karnataka'] ?? []);
  districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 0, 0),
            title: Stack(
              children: [
                Text(tr("Sign Up")),
                Positioned(
                  right: 4,
                  top: -8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: tr("Full Name"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      onChanged: (value) {
                        if (hasSubmitted) {
                          _formKey.currentState!.validate(); // Revalidate to clear error
                          setState(() {}); // Update UI
                        }
                      },
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? tr("Please enter your full name") : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      decoration: InputDecoration(
                        labelText: tr("District"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      hint: Text(tr("Select District")),
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
                          if (hasSubmitted) {
                            _formKey.currentState!.validate(); // Revalidate to clear error
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? tr("Please select a district") : null,
                    ),
                    const SizedBox(height: 10),
                    if (selectedDistrict != null)
                      DropdownButtonFormField<String>(
                        value: selectedTaluk,
                        decoration: InputDecoration(
                          labelText: tr("Taluk"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        hint: Text(tr("Select Taluk")),
                        items: taluks.map((taluk) {
                          return DropdownMenuItem(
                            value: taluk,
                            child: Text(taluk),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTaluk = value;
                            selectedVillage = null;
                            villagesList = value != null
                                ? List<String>.from(villagesMap[value] ?? [])
                                : [];
                            if (hasSubmitted) {
                              _formKey.currentState!.validate(); // Revalidate to clear error
                            }
                          });
                        },
                        validator: (value) =>
                            value == null ? tr("Please select a taluk") : null,
                      ),
                    const SizedBox(height: 10),
                    if (selectedTaluk != null)
                      DropdownButtonFormField<String>(
                        value: selectedVillage,
                        decoration: InputDecoration(
                          labelText: tr("Village"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        hint: Text(tr("Select Village")),
                        items: villagesList.map((village) {
                          return DropdownMenuItem(
                            value: village,
                            child: Text(village),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVillage = value;
                            if (hasSubmitted) {
                              _formKey.currentState!.validate(); // Revalidate to clear error
                            }
                          });
                        },
                        validator: (value) =>
                            value == null ? tr("Please select a village") : null,
                      ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pincodeController,
                      decoration: InputDecoration(
                        labelText: tr("Pincode"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: (value) {
                        if (hasSubmitted) {
                          _formKey.currentState!.validate(); // Revalidate to clear error
                          setState(() {}); // Update UI
                        }
                      },
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
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(tr("Submit")),
                onPressed: () async {
                  setState(() {
                    hasSubmitted = true; // Mark submission attempt
                  });

                  if (_formKey.currentState!.validate()) {
                    setState(() => isSubmitting = true);

                    try {
                      final userInsertUrl = Uri.parse("${KD.api}/user/insert_user");
                      final userInsertResponse = await http.post(
                        userInsertUrl,
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "phoneNumber": phone,
                          "fullName": _nameController.text.trim(),
                          "district": selectedDistrict,
                          "taluka": selectedTaluk,
                          "village": selectedVillage,
                          "pincode": _pincodeController.text.trim(),
                          "state": "Karnataka",
                        }),
                      );

                      final userInsertData = jsonDecode(userInsertResponse.body);

                      if (userInsertResponse.statusCode == 200 &&
                          userInsertData["status"] == "success") {
                        final generateOtpUrl =
                            Uri.parse("${KD.api}/admin/generate_otp");
                        final generateOtpResponse = await http.post(
                          generateOtpUrl,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "phoneNumber": phone,
                          }),
                        );
                        final generateOtpData = jsonDecode(generateOtpResponse.body);

                        if (generateOtpResponse.statusCode == 200 &&
                            generateOtpData["status"] == "success") {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr("Sign Up Initiated Successfully")),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OTPVerificationScreen(phoneNumber: phone),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  generateOtpData["message"] ?? tr("Failed to generate OTP")),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                userInsertData["message"] ?? tr("Registration failed")),
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
                },
              ),
            ],
          );
        },
      );
    },
  );
}