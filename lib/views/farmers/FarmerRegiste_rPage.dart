import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

import '../home/HomePage.dart';
import '../home/home_page2.dart';

class FarmerRegisterPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  final bool isUserExists; // Add a flag to check if user exists

  FarmerRegisterPage({required this.userData, required this.phoneNumber, required this.isUserExists});
  @override
  _FarmerRegisterPageState createState() => _FarmerRegisterPageState();
}

class _FarmerRegisterPageState extends State<FarmerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;



  // TextEditingControllers to manage form fields
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _pincodeController;



  Map<String, dynamic> locationData = {};
  List<String> states = [];
  List<String> districts = [];
  List<String> talukas = [];
  List<String> villages = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedTaluka;
  String? selectedVillage;

  @override
  void initState() {
    super.initState();
    loadLocationData();

    // Initialize controllers with user data
    _fullNameController = TextEditingController(
      text: widget.isUserExists ? (widget.userData['full_name'] ?? '') : '',
    );
    // Always pre-fill the phone number, regardless of user existence
    _phoneController = TextEditingController(
      text: widget.phoneNumber,
    );

    _pincodeController = TextEditingController(
      text: widget.isUserExists
          ? (widget.userData['pincode'] != null
          ? widget.userData['pincode'].toString() // Convert pincode to string if not null
          : '')
          : '',
    );
       // Pre-fill state and district dropdowns if the user exists
    if (widget.isUserExists) {
      selectedState = widget.userData['state'];
      selectedDistrict = widget.userData['district'];
      selectedTaluka = widget.userData['taluka'];
      selectedVillage = widget.userData['village'];
    }
  }

  Future<void> loadLocationData() async {
    final String response =
    await rootBundle.loadString('assets/loadLocation_data.json');
    final data = await json.decode(response);
    setState(() {
      locationData = data;
      states = List<String>.from(locationData['states']);
    });
  }

  void updateDistricts(String state) {
    setState(() {
      selectedDistrict = null;
      selectedTaluka = null;
      selectedVillage = null;
      districts = List<String>.from(locationData['districts'][state] ?? []);
      talukas = [];
      villages = [];
    });
  }

  void updateTalukas(String district) {
    setState(() {
      selectedTaluka = null;
      selectedVillage = null;
      talukas = List<String>.from(locationData['talukas'][district] ?? []);
      villages = [];
    });
  }

  void updateVillages(String taluka) {
    setState(() {
      selectedVillage = null;
      villages = List<String>.from(locationData['villages'][taluka] ?? []);
    });
  }






  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      final url = Uri.parse('http://3.110.121.159/api/user/insert_user');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': _fullNameController.text,
            'phoneNumber': _phoneController.text,
            'address': '',
            'pincode': int.tryParse(_pincodeController.text) ?? 0,
            'state': selectedState,
            'district': selectedDistrict,
            'taluka':selectedTaluka,
            'village': selectedVillage,
            'password': 'Securessword452', // Replace with user input or a secure value
            'orgId': '66c3467bd7d312820dd68d01', // Replace with dynamic orgId if needed
            'createdBy': 'admin',
          }),
        );

        final data = jsonDecode(response.body);

        print("Response data: $data"); // Print API response data for debugging

        if (response.statusCode == 200 && (data['status'] == 'success' || data['message'] == 'Farmer already exist')) {
          // Successfully registered; navigate to HomePage
          print("User registered successfully! Navigating to HomePage...");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(phoneNumber: widget.phoneNumber, userData:widget.userData),
            ),
          );
        } else {
          // Show error message from API response, such as "Farmer already exists"
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to register. Please try again.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error. Please check your connection.')),
        );
      } finally {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Row(
          children: [
            SizedBox(width: 8),
            Text(
              'PrachinTek'.tr(),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),

      ),
      body:SingleChildScrollView(
      child:Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    labelText: 'full_name'.tr(),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64), // Limit the input to 64 characters
                ],
                onChanged: (value) {
                  // Clear the error message when the user starts typing
                  setState(() {
                    _formKey.currentState!.validate();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a full_name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFF00AD83)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFF00AD83)),
                  ),
                  labelText:  'phone_number'.tr(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(10),  // Limit to 10 digits
                ],
                onChanged: (value) {
                  // Clear the error message when the user starts typing
                  setState(() {
                    _formKey.currentState!.validate();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide
                          : BorderSide(color: Color(0xFF00AD83)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    labelText: 'pincode'.tr(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(6),  // Limit to 10 digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pincode';
                  } else if (value.length != 6) {
                    return 'pincode must be 6 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // State Dropdown
              DropdownSearch<String>(
                items: states,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                  });
                  if (value != null) {
                    updateDistricts(value);
                  }
                },
                selectedItem: selectedState,
                validator: (value) =>
                value == null ? 'Please select a state' : null,

              ),
              SizedBox(height: 16),
              DropdownSearch<String>(
                items: districts,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'District',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                  });
                  if (value != null) {
                    updateTalukas(value);
                  }
                },
                selectedItem: selectedDistrict,
                validator: (value) =>
                value == null ? 'Please select a District' : null,
              ),
              SizedBox(height: 16),
              DropdownSearch<String>(
                items: talukas,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Taluka',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedTaluka = value;
                  });
                  if (value != null) {
                    updateVillages(value);
                  }
                },
                selectedItem: selectedTaluka,
                validator: (value) =>
                value == null ? 'Please select a Taluka' : null,
              ),
              SizedBox(height: 16),
              DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(labelText: 'Search Village'),
                  ),
                ),
                items: villages,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Village',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedVillage = value;
                  });
                },
                selectedItem: selectedVillage,
                validator: (value) =>
                value == null ? 'Please select a Village' : null,
              ),
              SizedBox(height: 35),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitForm,
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text (tr('save and continue'),
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00AD83),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}