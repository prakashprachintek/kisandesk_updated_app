import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, rootBundle;
import 'package:mainproject1/views/auth/MobileVerificationScreen.dart';
import 'package:mainproject1/views/services/user_session.dart';
import '../services/api_config.dart';

Future<Map<String, dynamic>> loadLocationJson() async {
  final String jsonString = await rootBundle.loadString('assets/loadLocation_data.json');
  return json.decode(jsonString);
}

Future<void> profileUpdateDialog(
  BuildContext context,
  String phone, {
  VoidCallback? onSuccess, // Added callback parameter
}) async {
  print("Dialog loaded");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hasSubmitted = false; // Track submission attempt
  bool isSubmitting = false;

  // Prepopulate fields with existing user data
  _nameController.text = UserSession.user?['full_name'] ?? "";
  _stateController.text = UserSession.user?['state'] ?? "Karnataka"; // Default to Karnataka if not set
  _pincodeController.text = UserSession.user?['pincode'] ?? "";
  _addressController.text = UserSession.user?['address'] ?? "";

  String? selectedDistrict = UserSession.user?['district'];
  String? selectedTaluk = UserSession.user?['taluka'];
  String? selectedVillage = UserSession.user?['village'];
  String? selectedGender = UserSession.user?['gender'];
  if (selectedGender != null && selectedGender.trim().isEmpty) {
    selectedGender = null;
  }
  DateTime? selectedDateOfBirth;
  if (UserSession.user?['dob'] != null) {
    try {
      selectedDateOfBirth = DateFormat('dd-MM-yyyy').parse(UserSession.user?['dob']);
    } catch (e) {
      selectedDateOfBirth = null;
    }
  } else {
    selectedDateOfBirth = null;
  }

  List<String> districts = [];
  List<String> taluks = [];
  List<String> villagesList = [];
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

  districts = List<String>.from(locationData['districts']['Karnataka'] ?? []);
  districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  // Set default district if none is selected
  if (selectedDistrict == null && districts.isNotEmpty) {
    selectedDistrict = districts.first;
  }

  // Validate and reset invalid location selections
  if (selectedDistrict != null && !districts.contains(selectedDistrict)) {
    selectedDistrict = null;
    selectedTaluk = null;
    selectedVillage = null;
  }

  // Always recompute taluks if district is set
  if (selectedDistrict != null) {
    taluks = List<String>.from(talukasMap[selectedDistrict] ?? []);
    if (selectedTaluk != null && !taluks.contains(selectedTaluk)) {
      selectedTaluk = null;
      selectedVillage = null;
    }
  } else {
    taluks = []; // Ensure empty if no district
  }

  // Always recompute villages if taluk is set
  if (selectedTaluk != null) {
    villagesList = List<String>.from(villagesMap[selectedTaluk] ?? []);
    if (selectedVillage != null && !villagesList.contains(selectedVillage)) {
      selectedVillage = null;
    }
  } else {
    villagesList = []; // Ensure empty if no taluk
  }

  // Debug print statements to track dropdown state
  print('DEBUG: selectedDistrict=$selectedDistrict, taluks=$taluks, selectedTaluk=$selectedTaluk');
  print('DEBUG: selectedTaluk=$selectedTaluk, villagesList=$villagesList, selectedVillage=$selectedVillage');

  // Define consistent InputDecoration for TextFields and Dropdowns
  InputDecoration _inputDecoration(String label) {
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
    );
  }

  // Function to check if all required fields are valid
  bool isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _pincodeController.text.trim().isNotEmpty &&
        _pincodeController.text.length == 6 &&
        selectedDistrict != null &&
        selectedTaluk != null &&
        selectedVillage != null &&
        selectedGender != null &&
        selectedDateOfBirth != null;
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              tr("Edit Personal Information"),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(tr('Name')),
                      onChanged: (value) {
                        if (hasSubmitted) {
                          _formKey.currentState!.validate();
                        }
                        setState(() {}); // Update button state
                      },
                      validator: (value) => value == null || value.trim().isEmpty
                          ? tr('Please enter your name')
                          : null,
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
                            if (hasSubmitted) {
                              _formKey.currentState!.validate();
                            }
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(tr('Date of Birth')),
                        child: Text(
                          selectedDateOfBirth == null
                              ? tr('Select Date')
                              : DateFormat('dd-MM-yyyy').format(selectedDateOfBirth!),
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Gender
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: _inputDecoration(tr('Gender')),
                      hint: Text(tr('Select Gender'), style: TextStyle(color: Colors.grey[600])),
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
                          if (hasSubmitted) {
                            _formKey.currentState!.validate();
                          }
                        });
                      },
                      validator: (value) => value == null ? tr('Please select a gender') : null,
                    ),
                    SizedBox(height: 10),
                    // State
                    TextFormField(
                      controller: _stateController,
                      decoration: _inputDecoration(tr('State')),
                      onChanged: (value) {
                        if (hasSubmitted) {
                          _formKey.currentState!.validate();
                        }
                        setState(() {}); // Update button state
                      },
                      validator: (value) => value == null || value.trim().isEmpty
                          ? tr('Please enter a state')
                          : null,
                    ),
                    SizedBox(height: 10),
                    // District
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      decoration: _inputDecoration(tr('District')),
                      hint: Text(tr('Select District'), style: TextStyle(color: Colors.grey[600])),
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
                          taluks = List<String>.from(talukasMap[selectedDistrict!] ?? []);
                          selectedTaluk = null;
                          villagesList = [];
                          selectedVillage = null;
                          if (hasSubmitted) {
                            _formKey.currentState!.validate();
                          }
                        });
                      },
                      validator: (value) => value == null ? tr('Please select a district') : null,
                    ),
                    SizedBox(height: 10),
                    // Taluka
                    DropdownButtonFormField<String>(
                      value: selectedTaluk,
                      decoration: _inputDecoration(tr('Taluka')),
                      hint: Text(
                        selectedDistrict == null ? tr('Select District first') : tr('Select Taluka'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      isExpanded: true,
                      items: taluks
                          .where((taluk) => taluk != null && taluk.isNotEmpty)
                          .map((taluk) {
                            return DropdownMenuItem(
                              value: taluk,
                              child: Text(taluk, style: TextStyle(color: Colors.black87)),
                            );
                          })
                          .toList(),
                      onChanged: selectedDistrict == null
                          ? null
                          : (value) {
                              setState(() {
                                selectedTaluk = value;
                                villagesList = List<String>.from(villagesMap[selectedTaluk!] ?? []);
                                print('DEBUG: Updated villagesList for taluk $selectedTaluk: $villagesList');
                                selectedVillage = null;
                                if (hasSubmitted) {
                                  _formKey.currentState!.validate();
                                }
                              });
                            },
                      validator: (value) =>
                          selectedDistrict != null && value == null ? tr('Please select a taluka') : null,
                    ),
                    SizedBox(height: 10),
                    // Village
                    DropdownButtonFormField<String>(
                      value: selectedVillage,
                      decoration: _inputDecoration(tr('Village')),
                      hint: Text(
                        selectedTaluk == null ? tr('Select Taluka first') : tr('Select Village'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      isExpanded: true,
                      items: villagesList
                          .where((village) => village != null)
                          .map((village) {
                            return DropdownMenuItem(
                              value: village,
                              child: Text(village, style: TextStyle(color: Colors.black87)),
                            );
                          })
                          .toList(),
                      onChanged: selectedTaluk == null
                          ? null
                          : (value) {
                              setState(() {
                                selectedVillage = value;
                                print('DEBUG: Selected village: $selectedVillage');
                                if (hasSubmitted) {
                                  _formKey.currentState!.validate();
                                }
                              });
                            },
                      validator: (value) =>
                          selectedTaluk != null && value == null ? tr('Please select a village') : null,
                    ),
                    SizedBox(height: 10),
                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration(tr('Address')),
                      onChanged: (value) {
                        if (hasSubmitted) {
                          _formKey.currentState!.validate();
                        }
                        setState(() {}); // Update button state
                      },
                      validator: (value) => value == null || value.trim().isEmpty
                          ? tr('Please enter an address')
                          : null,
                    ),
                    SizedBox(height: 10),
                    // Pincode
                    TextFormField(
                      controller: _pincodeController,
                      decoration: _inputDecoration(tr('Pincode')),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (hasSubmitted) {
                          _formKey.currentState!.validate();
                        }
                        setState(() {}); // Update button state
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr('Please enter a pincode');
                        }
                        if (value.length != 6) {
                          return tr('Pincode must be 6 digits');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
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
                      foregroundColor: isFormValid()
                          ? const Color.fromARGB(255, 29, 108, 92)
                          : Colors.grey[400],
                      backgroundColor: isFormValid()
                          ? Colors.transparent
                          : Colors.grey[200]?.withOpacity(0.5),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            tr("Update Details"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isFormValid() ? null : Colors.grey[600],
                            ),
                          ),
                    onPressed: () async {
                      setState(() {
                        hasSubmitted = true;
                      });

                      if (!_formKey.currentState!.validate()) {
                        setState(() => isSubmitting = false);
                        return;
                      }

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

                      if (!hasChanges) {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                tr("Error"),
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                              ),
                              content: Text(
                                tr("Please update at least one field"),
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color.fromARGB(255, 29, 108, 92),
                                  ),
                                  child: Text(
                                    tr("OK"),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
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
                        setState(() => isSubmitting = true);
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
                          // Update UserSession with new user data
                          if (data["userDataVal"] != null) {
                            await UserSession.setUser(data["userDataVal"]);
                            // Close the profile update dialog
                            Navigator.of(context).pop();
                            // Invoke callback to notify parent of success
                            onSuccess?.call();
                            // Show success alert dialog
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    tr("Success"),
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                                  ),
                                  content: Text(
                                    tr("Profile updated successfully"),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color.fromARGB(255, 29, 108, 92),
                                      ),
                                      child: Text(
                                        tr("OK"),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    tr("Error"),
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                                  ),
                                  content: Text(
                                    tr("Error: Updated user data not found"),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color.fromARGB(255, 29, 108, 92),
                                      ),
                                      child: Text(
                                        tr("OK"),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  tr("Error"),
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                                ),
                                content: Text(
                                  data["message"] ?? tr("Update failed"),
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(255, 29, 108, 92),
                                    ),
                                    child: Text(
                                      tr("OK"),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } catch (e) {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                tr("Error"),
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                              ),
                              content: Text(
                                tr("Error: $e"),
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color.fromARGB(255, 29, 108, 92),
                                  ),
                                  child: Text(
                                    tr("OK"),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
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