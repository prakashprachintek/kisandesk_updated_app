import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/api_config.dart';
import '../../main.dart';
import '../home/HomePage.dart';
import '../widgets/GradientAuthButton.dart';
import 'OTPVerificationScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadLocationJson() async {
  final String jsonString =
      await rootBundle.loadString('assets/loadLocation_data.json');
  return json.decode(jsonString);
}

class MobileVerificationScreen extends StatefulWidget {
  @override
  _MobileVerificationScreenState createState() =>
      _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  bool isValid10Digit(String phone) {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(phone);
  }

  Future<void> verifyPhoneNumber() async {
    final phone = phoneController.text.trim();

    if (!isValid10Digit(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Invalid phone number. Enter 10 digits."))),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("${KD.api}/admin/generate_otp");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNumber": phone}),
      );

      final data = jsonDecode(response.body);
      print("API1 Response: $data");

      if (response.statusCode == 200) {
        if (data["status"] == "success") {
          // Only proceed to OTP if the number exists in DB
          //number in the db 8862457812
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(phoneNumber: phone),
            ),
          );
        } else if (data["status"] == "failed") {
          // If number doesn't exist, show signup popup
          await _showSignupDialog(context, phone);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${data["message"] ?? "Unknown error"}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error. Try again.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showSignupDialog(BuildContext context, String phone) async {
    final TextEditingController _nameController = TextEditingController();
    _nameController.text = "";

    String? selectedDistrict;
    String? selectedTaluk;
    String? selectedVillage;

    List<String> districts = [];
    List<String> taluks = [];
    List<String> villagesList = [];

    Map<String, dynamic> locationData = await loadLocationJson();
    Map<String, List<dynamic>> talukasMap = Map.from(locationData['talukas']);
    Map<String, List<dynamic>> villagesMap = Map.from(locationData['villages']);
    districts = List<String>.from(locationData['districts']['Karnataka']);

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
                    ),
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
                        hint: Text(tr("Select Taluk")),
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
                    if (_nameController.text.isEmpty ||
                        selectedDistrict == null ||
                        selectedTaluk == null ||
                        selectedVillage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr("Please fill all fields"))),
                      );
                      return;
                    }

                    setState(() => isSubmitting = true);

                    try {
                      final url = Uri.parse(
                          "${KD.api}/user/insert_user");
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "phoneNumber": phone,
                          "fullName": _nameController.text.trim(),
                          "district": selectedDistrict,
                          "taluka": selectedTaluk,
                          "village": selectedVillage,
                        }),
                      );
                      print("Status Code: ${response.statusCode}");
                      print("Response Body: ${response.body}");

                      final data = jsonDecode(response.body);

                      if (response.statusCode == 200 &&
                          data["status"] == "success") {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(tr("Registration successful!"))),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OTPVerificationScreen(phoneNumber: phone),
                          ),
                        );

                        phoneController.clear(); // Assuming global
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  data["message"] ?? "Registration failed")),
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

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 16),
            Lottie.asset("assets/animations/phone.json",
                width: 180, height: 180),
            SizedBox(height: 20),
            Text(
              tr("Enter Your Phone Number"),
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20)),
            ),
            SizedBox(height: 12),
            Text(
              tr("We'll send an OTP to verify your number (+91)"),
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: tr("10-digit number"),
                prefixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 24),
            GradientAuthButton(
              text: isLoading ? tr("Checking...") : tr("Send OTP"),
              onTap: isLoading ? null : verifyPhoneNumber,
              textStyle: TextStyle(fontSize: 14),
            ),
            Spacer(),
            Text(tr("Need Help?"), style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
