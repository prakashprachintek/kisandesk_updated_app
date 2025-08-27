import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, rootBundle;
import 'package:mainproject1/views/profile/myProfile.dart';
import 'package:mainproject1/views/services/user_session.dart';
import '../services/api_config.dart';

Future<Map<String, dynamic>> loadLocationJson() async {
  final String jsonString =
      await rootBundle.loadString('assets/loadLocation_data.json');
  return json.decode(jsonString);
}

Future<void> profileUpdateDialog(BuildContext context, String phone) async {
  print("Dialog loaded");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  _nameController.text = "";
  _stateController.text = "Karnataka"; // Default state
  _pincodeController.text = "";
  _addressController.text = "";

  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedVillage;
  String? selectedGender;
  DateTime? selectedDateOfBirth;

  List<String> districts = [];
  List<String> taluks = [];
  List<String> villagesList = [];
  List<String> genders = ['Male', 'Female'];

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

  // Define consistent InputDecoration for TextFields and Dropdowns
  InputDecoration _inputDecoration(String label, {bool hasError = false}) {
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
      errorText: hasError ? 'This field is required' : null,
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
            title: Text(tr("Edit Personal Information"),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                        UserSession.user?['full_name'] ?? 'Name',
                        hasError: _nameError),
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
                        initialDate: DateTime.now(),
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
                      decoration: _inputDecoration('Date of Birth',
                          hasError: _dobError),
                      child: Text(
                        selectedDateOfBirth == null
                            ? 'Select Date'
                            : DateFormat('dd-MM-yyyy')
                                .format(selectedDateOfBirth!),
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Gender
                  InputDecorator(
                    decoration:
                        _inputDecoration('Gender', hasError: _genderError),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Select Gender',
                            style: TextStyle(color: Colors.grey[600])),
                        value: selectedGender,
                        isExpanded: true,
                        items: genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender,
                                style: TextStyle(color: Colors.black87)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                            _genderError = value == null;
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
                    decoration:
                        _inputDecoration('State', hasError: _stateError),
                    onChanged: (value) {
                      setState(() {
                        _stateError = value.isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // District
                  InputDecorator(
                    decoration: _inputDecoration(
                        UserSession.user?['district'] ?? 'District',
                        hasError: _districtError),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text(
                            UserSession.user?['district'] ?? 'Select District',
                            style: TextStyle(color: Colors.grey[600])),
                        value: selectedDistrict,
                        isExpanded: true,
                        items: districts.map((district) {
                          return DropdownMenuItem(
                            value: district,
                            child: Text(district,
                                style: TextStyle(color: Colors.black87)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            _districtError = value == null;
                            taluks = List<String>.from(
                                talukasMap[selectedDistrict!] ?? []);
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
                      decoration: _inputDecoration(
                          UserSession.user?["taluka"] ?? 'Taluka',
                          hasError: _talukError),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text(
                              UserSession.user?["taluka"] ?? 'Select Taluka',
                              style: TextStyle(color: Colors.grey[600])),
                          value: selectedTaluk,
                          isExpanded: true,
                          items: taluks.map((taluk) {
                            return DropdownMenuItem(
                              value: taluk,
                              child: Text(taluk,
                                  style: TextStyle(color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTaluk = value;
                              _talukError = value == null;
                              villagesList = List<String>.from(
                                  villagesMap[selectedTaluk!] ?? []);
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
                      decoration: _inputDecoration(
                          UserSession.user?["village"] ?? 'Village',
                          hasError: _villageError),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text(
                              UserSession.user?["village"] ?? 'Select Village',
                              style: TextStyle(color: Colors.grey[600])),
                          value: selectedVillage,
                          isExpanded: true,
                          items: villagesList.map((village) {
                            return DropdownMenuItem(
                              value: village,
                              child: Text(village,
                                  style: TextStyle(color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVillage = value;
                              _villageError = value == null;
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
                    decoration:
                        _inputDecoration('Address', hasError: _addressError),
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
                    decoration:
                        _inputDecoration('Pincode', hasError: _pincodeError),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      setState(() {
                        _pincodeError = value.length != 6;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(tr("Cancel"), style: TextStyle(color: Color.fromARGB(255, 35, 140, 110)),),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 29, 108, 92),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator()
                    : Text(tr("Update Details")),
                onPressed: () async {
                  setState(() {
                    isSubmitting = true;
                    _nameError = _nameController.text.isEmpty;
                    _stateError = _stateController.text.isEmpty;
                    _addressError = _addressController.text.isEmpty;
                    _pincodeError = _pincodeController.text.length != 6;
                    _districtError = selectedDistrict == null;
                    _talukError = selectedTaluk == null;
                    _villageError = selectedVillage == null;
                    _genderError = selectedGender == null;
                    _dobError = selectedDateOfBirth == null;
                  });

                  if (_nameController.text.isEmpty ||
                      _stateController.text.isEmpty ||
                      _addressController.text.isEmpty ||
                      selectedDistrict == null ||
                      selectedTaluk == null ||
                      selectedVillage == null ||
                      _pincodeController.text.length != 6 ||
                      selectedDateOfBirth == null ||
                      selectedGender == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr("Please fill all fields"))),
                    );
                    setState(() => isSubmitting = false);
                    return;
                  }

                  try {
                    final url = Uri.parse("${KD.api}/user/insert_user");
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "phoneNumber": phone,
                        "fullName": _nameController.text.trim(),
                        "state": _stateController.text.trim(),
                        "district": selectedDistrict,
                        "taluka": selectedTaluk,
                        "village": selectedVillage,
                        "address": _addressController.text.trim(),
                        "pincode": _pincodeController.text.trim(),
                        "dob": DateFormat('yyyy-MM-dd')
                            .format(selectedDateOfBirth!),
                        "gender": selectedGender,
                      }),
                    );
                    print("Status Code: ${response.statusCode}");
                    print("Response Body: ${response.body}");

                    final data = jsonDecode(response.body);

                    if (response.statusCode == 200 &&
                        data["status"] == "success") {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr("Registration successful!"))),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Myprofile(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text(data["message"] ?? "Registration failed")),
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
