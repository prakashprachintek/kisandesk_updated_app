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
    value.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  });

  villagesMap.forEach((key, value) {
    value.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
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
                Text(tr("Sign_Up")),
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
                        labelText: tr("full_Name"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
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
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      onChanged: (value) {
                        if (hasSubmitted) {
                          _formKey.currentState!
                              .validate(); // Revalidate to clear error
                          setState(() {}); // Update UI
                        }
                      },
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? tr("please_enter_full_name")
                              : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      decoration: InputDecoration(
                        labelText: tr("district"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
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
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      hint: Text(tr("please_select_district")),
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
                            _formKey.currentState!
                                .validate(); // Revalidate to clear error
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? tr("please_select_district") : null,
                    ),
                    const SizedBox(height: 10),
                    if (selectedDistrict != null)
                      DropdownButtonFormField<String>(
                        value: selectedTaluk,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: tr("taluka"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
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
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        hint: Text(tr("Please_enter_taluka")),
                        items: taluks.map((taluk) {
                          return DropdownMenuItem<String>(
                            value: taluk,
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                taluk,
                                overflow: TextOverflow
                                    .ellipsis, // 👈 Prevents overflow in menu item
                              ),
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
                            if (hasSubmitted) {
                              _formKey.currentState!
                                  .validate(); // Revalidate to clear error
                            }
                          });
                        },
                        validator: (value) =>
                            value == null ? tr("Please_enter_taluka") : null,
                      ),
                    const SizedBox(height: 10),
                    if (selectedTaluk != null)
                      DropdownButtonFormField<String>(
                        value: selectedVillage,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: tr("village"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
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
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        hint: Text(tr("please_enter_village")),
                        items: villagesList.map((village) {
                          return DropdownMenuItem<String>(
                            value: village,
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                village,
                                overflow: TextOverflow
                                    .ellipsis, // 👈 Prevents overflow in menu item
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVillage = value;
                            if (hasSubmitted) {
                              _formKey.currentState!
                                  .validate(); // Revalidate to clear error
                            }
                          });
                        },
                        validator: (value) => value == null
                            ? tr("please_enter_village")
                            : null,
                      ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pincodeController,
                      decoration: InputDecoration(
                        labelText: tr("pincode"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
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
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
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
                          _formKey.currentState!
                              .validate(); // Revalidate to clear error
                          setState(() {}); // Update UI
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr("please_enter_pincode");
                        }
                        if (value.length != 6) {
                          return tr("pincode_must_be_6_digits");
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
                    : Text(tr("submit")),
                onPressed: () async {
                  setState(() {
                    hasSubmitted = true; // Mark submission attempt
                  });

                  if (_formKey.currentState!.validate()) {
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
                          "district": selectedDistrict,
                          "taluka": selectedTaluk,
                          "village": selectedVillage,
                          "pincode": _pincodeController.text.trim(),
                          "state": "Karnataka",
                        }),
                      );

                      final userInsertData =
                          jsonDecode(userInsertResponse.body);

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
                                  Text(tr("Sign_Up_Initiated_Successfully")),
                            ),
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
                                  tr("Failed_to_generate_OTP")),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(userInsertData["message"] ??
                                tr("Registration_failed")),
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


Future<void> showSignupBottomSheet(BuildContext context, String phone) async {
  print("Bottom sheet loaded");
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

  Map<String, dynamic> locationData = await loadLocationJson();

  // Copy and sort maps
  Map<String, List<dynamic>> talukasMap = Map.from(locationData['talukas']);
  Map<String, List<dynamic>> villagesMap = Map.from(locationData['villages']);

  talukasMap.forEach((key, value) {
    value.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  });

  villagesMap.forEach((key, value) {
    value.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  });

  districts = List<String>.from(locationData['districts']['Karnataka'] ?? []);
  districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
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
                              tr("Sign_Up"),
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
                        const SizedBox(height: 16),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: tr("full_Name"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) {
                            if (hasSubmitted) _formKey.currentState!.validate();
                          },
                          validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? tr("Please_enter_full_name")
                              : null,
                        ),
                        const SizedBox(height: 10),

                        // District
                        DropdownButtonFormField<String>(
                          value: selectedDistrict,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: tr("district"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: Text(tr("please_select_district")),
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
                          value == null ? tr("please_select_district") : null,
                        ),
                        const SizedBox(height: 10),

                        // Taluk
                        if (selectedDistrict != null)
                          DropdownButtonFormField<String>(
                            value: selectedTaluk,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: tr("taluka"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            hint: Text(tr("please_enter_taluka")),
                            items: taluks.map((taluk) {
                              return DropdownMenuItem(
                                value: taluk,
                                child: Text(taluk, overflow: TextOverflow.ellipsis),
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
                            value == null ? tr("please_enter_taluka") : null,
                          ),
                        const SizedBox(height: 10),

                        // Village
                        if (selectedTaluk != null)
                          DropdownButtonFormField<String>(
                            value: selectedVillage,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: tr("village"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            hint: Text(tr("please_enter_village")),
                            items: villagesList.map((village) {
                              return DropdownMenuItem(
                                value: village,
                                child: Text(village,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedVillage = value);
                            },
                            validator: (value) =>
                            value == null ? tr("please_enter_village") : null,
                          ),
                        const SizedBox(height: 10),

                        // Pincode
                        TextFormField(
                          controller: _pincodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            labelText: tr("pincode"),
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return tr("please_enter_pincode");
                            }
                            if (value.length != 6) {
                              return tr("pincode_must_be_6_digits");
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                              setState(() => hasSubmitted = true);

                              if (_formKey.currentState!.validate()) {
                                setState(() => isSubmitting = true);
                                try {
                                  final userInsertUrl =
                                  Uri.parse("${KD.api}/user/insert_user");
                                  final response = await http.post(
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

                                  final data = jsonDecode(response.body);

                                  if (response.statusCode == 200 &&
                                      data["status"] == "success") {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(tr("Sign_Up_Initiated_Successfully")),
                                      ),
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
                                        content: Text(data["message"] ??
                                            tr("Registration_failed")),
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
                            child: isSubmitting
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : Text(tr("submit")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
