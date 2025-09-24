import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/api_config.dart';
import 'OTPVerificationScreen.dart';

// Load location JSON (moved from the original file)
Future<Map<String, dynamic>> loadLocationJson() async {
  final String jsonString =
      await rootBundle.loadString('assets/loadLocation_data.json');
  return json.decode(jsonString);
}

Future<void> showSignupDialog(BuildContext context, String phone) async {
  print("Dialog loaded");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  _nameController.text = "";
  _pincodeController.text = "";

  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedVillage;

  List<String> districts = [];
  List<String> taluks = [];
  List<String> villagesList = [];

  Map<String, dynamic> locationData = await loadLocationJson();

  // Copy the maps
  Map<String, List<dynamic>> talukasMap = Map.from(locationData['talukas']);
  Map<String, List<dynamic>> villagesMap = Map.from(locationData['villages']);

  // Sort the lists inside each map
  talukasMap.forEach((key, value) {
    value.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  });

  villagesMap.forEach((key, value) {
    value.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  });

  // Sort the districts list
  districts = List<String>.from(locationData['districts']['Karnataka'] ?? []);
  districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  bool isSubmitting = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(tr("Sign Up")),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: tr("Full Name")),
                  ),/*
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    hint: Text(tr("Select District")),
                    value: selectedDistrict,
                    isExpanded: true,
                    items: districts.map((district) {
                      return DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                        taluks = List<String>.from(
                            talukasMap[selectedDistrict!] ?? []);
                        selectedTaluk = null;
                        villagesList = [];
                        selectedVillage = null;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  if (selectedDistrict != null)
                    DropdownButton<String>(
                      hint: Text(tr("Select Taluka")),
                      value: selectedTaluk,
                      isExpanded: true,
                      items: taluks.map((taluk) {
                        return DropdownMenuItem(
                          value: taluk,
                          child: Text(taluk),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTaluk = value;
                          villagesList = List<String>.from(
                              villagesMap[selectedTaluk!] ?? []);
                          selectedVillage = null;
                        });
                      },
                    ),
                  SizedBox(height: 10),
                  if (selectedTaluk != null)
                    DropdownButton<String>(
                      hint: Text(tr("Select Village")),
                      value: selectedVillage,
                      isExpanded: true,
                      items: villagesList.map((village) {
                        return DropdownMenuItem(
                          value: village,
                          child: Text(village),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVillage = value;
                        });
                      },
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _pincodeController,
                    decoration: InputDecoration(labelText: tr("Pincode")),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  */
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(tr("Cancel")),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: isSubmitting
                    ? CircularProgressIndicator()
                    : Text(tr("Submit")),
                onPressed: () async {
                  if (_nameController.text.isEmpty 
                  // ||
                      // selectedDistrict == null ||
                      // selectedTaluk == null ||
                      // selectedVillage == null ||
                      // _pincodeController.text.isEmpty
                      ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr("Please fill all fields"))),
                    );
                    return;
                  }

                  setState(() => isSubmitting = true);

                  try {
                    // 1. Attempt to insert user
                    final userInsertUrl =
                        Uri.parse("${KD.api}/user/insert_user");
                    final userInsertResponse = await http.post(
                      userInsertUrl,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "phoneNumber": phone,
                        "fullName": _nameController.text.trim(),
                        // "district": selectedDistrict,
                        // "taluka": selectedTaluk,
                        // "village": selectedVillage,
                        // "pincode": _pincodeController.text.trim(),
                        "state": "Karnataka",
                      }),
                    );

                    final userInsertData = jsonDecode(userInsertResponse.body);

                    if (userInsertResponse.statusCode == 200 &&
                        userInsertData["status"] == "success") {
                      // 2. If user insertion is successful, generate OTP
                      final generateOtpUrl =
                          Uri.parse("${KD.api}/admin/generate_otp");
                      final generateOtpResponse = await http.post(
                        generateOtpUrl,
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "phoneNumber": phone,
                        }),
                      );
                      final generateOtpData =
                          jsonDecode(generateOtpResponse.body);

                      if (generateOtpResponse.statusCode == 200 &&
                          generateOtpData["status"] == "success") {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(tr("Registration successful!"))),
                        );
                        // 3. Navigate to OTP verification screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OTPVerificationScreen(phoneNumber: phone),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(generateOtpData["message"] ??
                                  "Failed to generate OTP")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                userInsertData["message"] ?? "Registration failed")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  } finally {
                    setState(() => isSubmitting = false);
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