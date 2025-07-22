/**/
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../widgets/AuthOptionCard.dart';
import 'MobileVerificationScreen.dart';
import '../home/HomePage.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset('assets/animations/login.json'),
                      ),
                      SizedBox(height: 16),
                      Text(
                        tr("Welcome to Kisan Desk!"),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        tr("Choose your preferred sign-in method below"),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      AuthOptionCard(
                        lottieFile: 'assets/animations/phone.json',
                        title: tr("Mobile OTP"),
                        subtitle: tr("Login with your phone number"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MobileVerificationScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24),
                      /*
                      TextButton(
                        onPressed: () => _showSignupDialog(context),
                        child: Text(
                          "Don’t have an account? Sign Up",
                          style: TextStyle(
                            color: Color(0xFF00AD83),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      */

                      // comment this section before release
                      //added for development purposes only
                      ////////////////////////////////////
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1B5E20), // Greenish-teal
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            elevation: 4,
                          ),
                          child: Text(
                            tr("🚀 Skip to Home (Dev Only)"),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      //////////////////////////////////////
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  // Future<void> _showSignupDialog(BuildContext context) async {
  //   final TextEditingController _phoneController = TextEditingController();
  //   final TextEditingController _nameController = TextEditingController();

  //   String? selectedDistrict;
  //   String? selectedTaluk;
  //   String? selectedVillage;

  //   final Map<String, List<String>> districtTaluks = {
  //     'Bangalore': ['BTM', 'Indiranagar'],
  //     'Mysore': ['Nazarbad', 'VV Mohalla'],
  //   };

  //   final Map<String, List<String>> talukVillages = {
  //     'BTM': ['BTM Layout 1st Stage', 'BTM Layout 2nd Stage'],
  //     'Indiranagar': ['HAL', 'Domlur'],
  //     'Nazarbad': ['Ashokpuram', 'Chamundi Hill'],
  //     'VV Mohalla': ['Gokulam', 'Jayanagar Mysore'],
  //   };

  //   List<String> districts = districtTaluks.keys.toList();
  //   List<String> taluks = [];
  //   List<String> villages = [];

  //   await showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text("Sign Up"),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     controller: _phoneController,
  //                     decoration: InputDecoration(labelText: "Phone Number"),
  //                     keyboardType: TextInputType.phone,
  //                   ),
  //                   SizedBox(height: 10),
  //                   TextField(
  //                     controller: _nameController,
  //                     decoration: InputDecoration(labelText: "Full Name"),
  //                   ),
  //                   SizedBox(height: 10),
  //                   DropdownButton<String>(
  //                     hint: Text("Select District"),
  //                     value: selectedDistrict,
  //                     isExpanded: true,
  //                     items: districts.map((district) {
  //                       return DropdownMenuItem(
  //                         value: district,
  //                         child: Text(district),
  //                       );
  //                     }).toList(),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         selectedDistrict = value;
  //                         taluks = districtTaluks[value!] ?? [];
  //                         selectedTaluk = null;
  //                         villages = [];
  //                         selectedVillage = null;
  //                       });
  //                     },
  //                   ),
  //                   SizedBox(height: 10),
  //                   DropdownButton<String>(
  //                     hint: Text("Select Taluk"),
  //                     value: selectedTaluk,
  //                     isExpanded: true,
  //                     items: taluks.map((taluk) {
  //                       return DropdownMenuItem(
  //                         value: taluk,
  //                         child: Text(taluk),
  //                       );
  //                     }).toList(),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         selectedTaluk = value;
  //                         villages = talukVillages[value!] ?? [];
  //                         selectedVillage = null;
  //                       });
  //                     },
  //                   ),
  //                   SizedBox(height: 10),
  //                   DropdownButton<String>(
  //                     hint: Text("Select Village"),
  //                     value: selectedVillage,
  //                     isExpanded: true,
  //                     items: villages.map((village) {
  //                       return DropdownMenuItem(
  //                         value: village,
  //                         child: Text(village),
  //                       );
  //                     }).toList(),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         selectedVillage = value;
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 child: Text("Cancel"),
  //                 onPressed: () => Navigator.of(context).pop(),
  //               ),
  //               ElevatedButton(
  //                 child: Text("Submit"),
  //                 onPressed: () async {
  //                   if (_phoneController.text.isEmpty ||
  //                       _nameController.text.isEmpty ||
  //                       selectedDistrict == null ||
  //                       selectedTaluk == null ||
  //                       selectedVillage == null) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text("Please fill all fields")),
  //                     );
  //                     return;
  //                   }

  //                   // ✅ For now, skip API call, just navigate to HomePage
  //                   Navigator.of(context).pop(); // close the dialog
  //                   Navigator.of(context).pushReplacement(
  //                     MaterialPageRoute(
  //                       builder: (_) => HomePage(
  //                         phoneNumber: _phoneController.text.trim(),
  //                         userData: {
  //                           'fullName': _nameController.text.trim(),
  //                           'district': selectedDistrict,
  //                           'taluka': selectedTaluk,
  //                           'village': selectedVillage,
  //                         },
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
// }
