import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/api_config.dart';
import 'OTPVerificationScreen.dart';

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
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
                          width: 2.0
                        ),
                      ),
                    
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                  ),
                  /*
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    // ... (Dropdowns remain commented out)
                  ),
                  SizedBox(height: 10),
                  if (selectedDistrict != null)
                    DropdownButton<String>(
                      // ...
                    ),
                  SizedBox(height: 10),
                  if (selectedTaluk != null)
                    DropdownButton<String>(
                      // ...
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _pincodeController,
                    decoration: InputDecoration(
                      labelText: tr("Pincode"),
                      // Apply the same border logic here if uncommented:
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, 
                          width: 2.0
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  */
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                child: isSubmitting
                    ? const CircularProgressIndicator()
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