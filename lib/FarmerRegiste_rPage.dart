import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Home_page.dart';

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

  // Define lists for states and districts
  final List<String> _states = ['Karnataka', 'Maharashtra'];
  final Map<String, List<String>> _districts = {
    'Karnataka': ["Bagalkot",
    "Ballari (Bellary)",
    "Belagavi (Belgaum)",
    "Bengaluru Rural",
    "Bengaluru Urban",
    "Bidar",
    "Chamarajanagar",
    "Chikkaballapur",
    "Chikkamagaluru (Chikmagalur)",
    "Chitradurga",
    "Dakshina Kannada (Mangalore)",
    "Davanagere",
    "Dharwad",
    "Gadag",
    "Hassan",
    "Haveri",
    "Kalaburagi",
    "Kodagu (Coorg)",
    "Kolar",
    "Koppal",
    "Mandya",
    "Mysuru (Mysore)",
    "Raichur",
    "Ramanagara",
    "Shivamogga (Shimoga)",
    "Tumakuru (Tumkur)",
    "Udupi",
    "Uttara Kannada (Karwar)",
    "Vijayapura (Bijapur)",
    "Yadgir"],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur']
  };

  // Selected values for state and district dropdowns
  String? _selectedState;
  String? _selectedDistrict;



  // TextEditingControllers to manage form fields
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _pincodeController;

  late TextEditingController _talukaController;
  late TextEditingController _villageController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with user data
    _fullNameController = TextEditingController(
      text: widget.isUserExists ? (widget.userData['full_name'] ?? '') : '',
    );
    // Always pre-fill the phone number, regardless of user existence
    _phoneController = TextEditingController(
      text: widget.phoneNumber,
    );
    _addressController = TextEditingController(
      text: widget.isUserExists ? widget.userData['address'] ?? '' : '',
    );
    _pincodeController = TextEditingController(
      text: widget.isUserExists
          ? (widget.userData['pincode'] != null
          ? widget.userData['pincode'].toString() // Convert pincode to string if not null
          : '')
          : '',
    );
    _talukaController = TextEditingController(
      text: widget.isUserExists ? widget.userData['taluka'] ?? '' : '',
    );
    _villageController = TextEditingController(
      text: widget.isUserExists ? widget.userData['village'] ?? '' : '',
    );

    // Pre-fill state and district dropdowns if the user exists
    if (widget.isUserExists) {
      _selectedState = widget.userData['state'];
      _selectedDistrict = widget.userData['district'];
    }
  }




  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _talukaController.dispose();
    _villageController.dispose();
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
            'address': _addressController.text,
            'pincode': int.tryParse(_pincodeController.text) ?? 0,
            'state': _selectedState,
            'district': _selectedDistrict,
            'taluka': _talukaController.text,
            'village': _villageController.text,
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
              'PrachinTek',
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
                    labelText: 'Full Name'
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64), // Limit the input to 64 characters
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
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
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(10),  // Limit to 10 digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    labelText: 'Address'
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64), // Limit the input to 64 characters
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
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
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    labelText: 'Pincode'
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
              DropdownButtonFormField<String>(
                value: _selectedState,
                items: _states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _selectedDistrict = null; // Reset district if state changes
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  labelText: 'State',
                ),
                validator: (value) => value == null ? 'Please select a state' : null,
              ),
              SizedBox(height: 20),

              // District Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                items: _selectedState != null
                    ? _districts[_selectedState!]!.map((String district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  labelText: 'District',
                ),
                validator: (value) => value == null ? 'Please select a district' : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller:_talukaController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    labelText: 'taluka'
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64), // Limit the input to 64 characters
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your taluka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _villageController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF00AD83)),
                    ),
                    labelText: 'village'
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64), // Limit the input to 64 characters
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your village';
                  }
                  return null;
                },
              ),
              SizedBox(height: 35),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitForm,
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save and Continue',
                  style: TextStyle(color: Colors.white),),
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

