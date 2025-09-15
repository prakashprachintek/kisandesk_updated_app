import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, rootBundle;
import 'package:mainproject1/views/profile/personalDetailsPage.dart';
import 'package:mainproject1/views/auth/MobileVerificationScreen.dart';
import 'package:mainproject1/views/services/user_session.dart';
import '../services/api_config.dart';

Future<Map<String, dynamic>> loadLocationJson() async {
  final String jsonString = await rootBundle.loadString('assets/loadLocation_data.json');
  return json.decode(jsonString);
}

Future<void> profileUpdateDialog(BuildContext context, String phone) async {
  print("Dialog loaded");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Prepopulate fields with existing user data
  _nameController.text = UserSession.user?['full_name'] ?? "";
  _stateController.text = UserSession.user?['state'] ?? "Karnataka"; // Default to Karnataka if not set
  _pincodeController.text = UserSession.user?['pincode'] ?? "";
  _addressController.text = UserSession.user?['address'] ?? "";

  String? selectedDistrict = UserSession.user?['district'];
  String? selectedTaluk = UserSession.user?['taluka'];
  String? selectedVillage = UserSession.user?['village'];
  String? selectedGender = UserSession.user?['gender'];
  DateTime? selectedDateOfBirth = UserSession.user?['dob'] != null
      ? DateFormat('dd-MM-yyyy').parse(UserSession.user?['dob'])
      : null;

  List<String> districts = [];
  List<String> taluks = selectedDistrict != null
      ? List<String>.from((await loadLocationJson())['talukas'][selectedDistrict] ?? [])
      : [];
  List<String> villagesList = selectedTaluk != null
      ? List<String>.from((await loadLocationJson())['villages'][selectedTaluk] ?? [])
      : [];
  List<String> genders = ['Male', 'Female'];

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

  // Sort the districts list
  districts = List<String>.from(locationData['districts']['Karnataka'] ?? []);
  districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  bool isSubmitting = false;

  // Define consistent InputDecoration for TextFields and Dropdowns
  InputDecoration _inputDecoration(String label, {bool hasError = false, String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      errorText: hasError ? (errorText ?? 'This field is invalid') : null,
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Track error states for all fields
          bool _nameError = false;
          bool _stateError = false;
          bool _addressError = false;
          bool _pincodeError = false;
          bool _districtError = false;
          bool _talukError = false;
          bool _villageError = false;
          bool _genderError = false;
          bool _dobError = false;

          return AlertDialog(
            title: Text(
              tr("Edit Personal Information"),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('Name', hasError: _nameError),
                    onChanged: (value) {
                      setState(() {
                        _nameError = value.isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // Date of Birth
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDateOfBirth ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDateOfBirth = picked;
                          _dobError = false;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: _inputDecoration('Date of Birth', hasError: _dobError),
                      child: Text(
                        selectedDateOfBirth == null
                            ? 'Select Date'
                            : DateFormat('dd-MM-yyyy').format(selectedDateOfBirth!),
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Gender
                  InputDecorator(
                    decoration: _inputDecoration('Gender', hasError: _genderError),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Select Gender', style: TextStyle(color: Colors.grey[600])),
                        value: selectedGender,
                        isExpanded: true,
                        items: genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender, style: TextStyle(color: Colors.black87)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                            _genderError = false;
                          });
                        },
                        style: TextStyle(color: Colors.black87),
                        dropdownColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // State
                  TextField(
                    controller: _stateController,
                    decoration: _inputDecoration('State', hasError: _stateError),
                    onChanged: (value) {
                      setState(() {
                        _stateError = value.isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // District
                  InputDecorator(
                    decoration: _inputDecoration('District', hasError: _districtError),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Select District', style: TextStyle(color: Colors.grey[600])),
                        value: selectedDistrict,
                        isExpanded: true,
                        items: districts.map((district) {
                          return DropdownMenuItem(
                            value: district,
                            child: Text(district, style: TextStyle(color: Colors.black87)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            _districtError = false;
                            taluks = List<String>.from(talukasMap[selectedDistrict!] ?? []);
                            selectedTaluk = null;
                            _talukError = false;
                            villagesList = [];
                            selectedVillage = null;
                            _villageError = false;
                          });
                        },
                        style: TextStyle(color: Colors.black87),
                        dropdownColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Taluka
                  if (selectedDistrict != null)
                    InputDecorator(
                      decoration: _inputDecoration('Taluka', hasError: _talukError),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text('Select Taluka', style: TextStyle(color: Colors.grey[600])),
                          value: selectedTaluk,
                          isExpanded: true,
                          items: taluks.map((taluk) {
                            return DropdownMenuItem(
                              value: taluk,
                              child: Text(taluk, style: TextStyle(color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTaluk = value;
                              _talukError = false;
                              villagesList = List<String>.from(villagesMap[selectedTaluk!] ?? []);
                              selectedVillage = null;
                              _villageError = false;
                            });
                          },
                          style: TextStyle(color: Colors.black87),
                          dropdownColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  if (selectedDistrict != null) SizedBox(height: 10),
                  // Village
                  if (selectedTaluk != null)
                    InputDecorator(
                      decoration: _inputDecoration('Village', hasError: _villageError),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text('Select Village', style: TextStyle(color: Colors.grey[600])),
                          value: selectedVillage,
                          isExpanded: true,
                          items: villagesList.map((village) {
                            return DropdownMenuItem(
                              value: village,
                              child: Text(village, style: TextStyle(color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVillage = value;
                              _villageError = false;
                            });
                          },
                          style: TextStyle(color: Colors.black87),
                          dropdownColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  if (selectedTaluk != null) SizedBox(height: 10),
                  // Address
                  TextField(
                    controller: _addressController,
                    decoration: _inputDecoration('Address', hasError: _addressError),
                    onChanged: (value) {
                      setState(() {
                        _addressError = value.isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // Pincode
                  TextField(
                    controller: _pincodeController,
                    decoration: _inputDecoration(
                      'Pincode',
                      hasError: _pincodeError,
                      errorText: _pincodeController.text.isNotEmpty && _pincodeController.text.length != 6
                          ? 'Pincode must be 6 digits'
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        _pincodeError = value.isNotEmpty && value.length != 6;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text(
                      tr("Cancel"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 29, 108, 92),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            tr("Update Details"),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                    onPressed: () async {
                      setState(() {
                        isSubmitting = true;
                        _nameError = _nameController.text.isEmpty;
                        _stateError = _stateController.text.isEmpty;
                        _addressError = _addressController.text.isEmpty;
                        _pincodeError = _pincodeController.text.isNotEmpty && _pincodeController.text.length != 6;
                        _districtError = selectedDistrict == null;
                        _talukError = selectedDistrict != null && selectedTaluk == null;
                        _villageError = selectedTaluk != null && selectedVillage == null;
                        _genderError = selectedGender == null;
                        _dobError = selectedDateOfBirth == null;
                      });

                      // Check if at least one field has been provided or changed
                      bool hasChanges = _nameController.text.isNotEmpty ||
                          _stateController.text.isNotEmpty ||
                          _addressController.text.isNotEmpty ||
                          _pincodeController.text.isNotEmpty ||
                          selectedDistrict != null ||
                          selectedTaluk != null ||
                          selectedVillage != null ||
                          selectedGender != null ||
                          selectedDateOfBirth != null;

                      // Validate only provided fields
                      if (!hasChanges) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("Please update at least one field"))),
                        );
                        setState(() => isSubmitting = false);
                        return;
                      }

                      // Validate pincode if provided
                      if (_pincodeController.text.isNotEmpty && _pincodeController.text.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("Pincode must be 6 digits"))),
                        );
                        setState(() => isSubmitting = false);
                        return;
                      }

                      // Validate taluka and village if district or taluka is provided
                      if (selectedDistrict != null && selectedTaluk == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("Please select a taluka"))),
                        );
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (selectedTaluk != null && selectedVillage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("Please select a village"))),
                        );
                        setState(() => isSubmitting = false);
                        return;
                      }

                      // Build the payload dynamically
                      Map<String, dynamic> payload = {"_id": UserSession.user?["_id"]};
                      if (_nameController.text.isNotEmpty) {
                        payload["fullName"] = _nameController.text.trim();
                      }
                      if (_stateController.text.isNotEmpty) {
                        payload["state"] = _stateController.text.trim();
                      }
                      if (selectedDistrict != null) {
                        payload["district"] = selectedDistrict;
                      }
                      if (selectedTaluk != null) {
                        payload["taluka"] = selectedTaluk;
                      }
                      if (selectedVillage != null) {
                        payload["village"] = selectedVillage;
                      }
                      if (_addressController.text.isNotEmpty) {
                        payload["address"] = _addressController.text.trim();
                      }
                      if (_pincodeController.text.isNotEmpty) {
                        payload["pincode"] = _pincodeController.text.trim();
                      }
                      if (selectedDateOfBirth != null) {
                        payload["dob"] = DateFormat('dd-MM-yyyy').format(selectedDateOfBirth!);
                      }
                      if (selectedGender != null) {
                        payload["gender"] = selectedGender;
                      }

                      // API Call to submit the data
                      try {
                        final url = Uri.parse("${KD.api}/user/update_user");
                        final response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(payload),
                        );
                        print("Status Code: ${response.statusCode}");
                        print("Response Body: ${response.body}");

                        final data = jsonDecode(response.body);

                        if (response.statusCode == 200 && data["status"] == "success") {
                          // Close the profile update dialog
                          Navigator.of(context).pop();
                          // Show new alert dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  tr("Profile Updated"),
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                                ),
                                content: Text(
                                  tr("Profile updated. Please re-login to see the changes"),
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(255, 29, 108, 92),
                                    ),
                                    child: Text(
                                      tr("Login"),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the alert
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => MobileVerificationScreen()),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(data["message"] ?? "Update failed")),
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
              ),
            ],
          );
        },
      );
    },
  );
}