import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:flutter/services.dart';

import 'Home_page.dart';

class AddMarketPostPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  AddMarketPostPage({required this.userData, required this.phoneNumber});

  @override
  _AddMarketPostPageState createState() => _AddMarketPostPageState();
}

class _AddMarketPostPageState extends State<AddMarketPostPage> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  // Controllers
  final _cropNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _TalukaController = TextEditingController();
  final _villageController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _errorText;

  // State Variables
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCategory;
  File? _selectedImage;

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Category-specific Labels
  final Map<String, Map<String, String>> _categoryFieldLabels = {
    'cattle': {
      'cropName': 'Cattle Name',
      'description': 'Cattle Description',
      'price': 'Price',
      'quantity': 'Number of Cattle',
    },
    'farmer': {
      'cropName': 'Crop Name',
      'description': 'Crop Description',
      'price': 'Price',
      'quantity': 'Quantity (kg)',
    },
    'land': {
      'cropName': 'Land Name',
      'description': 'Land Description',
      'price': 'Price per Acre',
      'quantity': 'Total Area (Acres)',
    },
    'Labour': {
      'cropName': 'Job Role',
      'description': 'Job Description',
      'price': 'Wages per Day',
      'quantity': 'Number of Workers Needed',
    },
    'machinery': {
      'cropName': 'Machine Name',
      'description': 'Machine Description',
      'price': 'Price',
      'quantity': 'Quantity Available',
    },
    'adati': {
      'cropName': 'cropName',
      'description': 'description',
      'price': 'Price',
      'quantity': 'Quantity',
    },

  };

  Map<String, String> _currentFieldLabels = {
    'cropName': 'Title',
    'description': 'Description',
    'price': 'Price',
    'quantity': 'Quantity',
  };


  final Map<String, List<String>> _districtsByState = {
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
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
  };

  // final List<String> _categories = [
  //   'Cattle',
  //   'Farmer',
  //   'Land',
  //   'Labour',
  //   'Machinery',
  // ];


  @override
  void initState() {
    super.initState();

    // Pre-fill fields from userData
    _selectedState = widget.userData['state'];
    _selectedDistrict = widget.userData['district'];
    _TalukaController.text = widget.userData['taluka'] ?? '';
    _villageController.text = widget.userData['village'] ?? '';
    _pincodeController.text = (widget.userData['pincode'] ?? '').toString();
    _phoneNumberController.text = widget.userData['phone'] ?? '';
    _updateFieldLabels('farmer'); // Default category




  }


  void _updateFieldLabels(String? category) {
    if (category != null && _categoryFieldLabels.containsKey(category)) {
      setState(() {
        _currentFieldLabels = _categoryFieldLabels[category]!;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitMarketPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      final url = Uri.parse(
          'http://3.110.121.159/api/admin/insert_market_post');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "farmer_id": widget.userData['farmer_id'],
            "phoneNumber": _phoneNumberController.text,
            "cropName": _cropNameController.text,
            "description": _descriptionController.text,
            "price": int.tryParse(_priceController.text) ?? 0,
            "quantity": int.tryParse(_quantityController.text) ?? 0,
            "state": _selectedState,
            "district": _selectedDistrict,
            "taluka": _TalukaController.text,
            "village": _villageController.text,
            "pincode": _pincodeController.text,
            "category": _selectedCategory,
            "image": _selectedImage != null ? base64Encode(
                _selectedImage!.readAsBytesSync()) : null,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Show success dialog and navigate to HomePage after success
          showDialog(
            context: context,
            barrierDismissible: false,
            // Prevent dismissing the dialog by tapping outside
            builder: (context) =>
                AlertDialog(
                  title: Text('Submission'),
                  content: Text(
                      'Are you sure you want to submit the\n market post?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                          'No', style: TextStyle(color: Color(0xFF00AD83))),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              HomePage(phoneNumber: widget.phoneNumber,
                                  userData: widget.userData)),
                          // Replace HomePage with your actual home page widget
                              (route) => false,
                        );
                      },
                      child: Text(
                          'Yes', style: TextStyle(color: Color(0xFF00AD83))),
                    ),
                  ],
                ),
          );
        } else {
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: Text('Error'),
                  content: Text(data['message'] ?? 'Failed to add post.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                          'OK', style: TextStyle(color: Color(0xFF00AD83))),
                    ),
                  ],
                ),
          );
        }
      } catch (error) {
        // Show network error dialog
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Error'),
                content: Text('Network error. Please check your connection.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                        'OK', style: TextStyle(color: Color(0xFF00AD83))),
                  ),
                ],
              ),
        );
      }
      finally {
        setState(() => isSubmitting = false);
      }
    }
  }



  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFF00AD83)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFF00AD83)),
      ),
      labelText: labelText,
      labelStyle: TextStyle(color: Color(0xFF00AD83)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Text(
          "Add Market Post",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child:Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: _buildInputDecoration('Category'),
              value: _selectedCategory,
              items: _categoryFieldLabels.keys.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(capitalize(category)),
                );
              }).toList(),
              onChanged: (value) {
                _updateFieldLabels(value);
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) => value == null ? 'Please select a Category' : null,
            ),
            if (_selectedCategory == 'cattle') ...[
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration('Cattle Name'),
                value: _cropNameController.text.isEmpty ? null : _cropNameController.text,
                items: ['Cow', 'Buffalo', 'Ox', 'Goat', 'Other'].map((cattle) {
                  return DropdownMenuItem(
                    value: cattle,
                    child: Text(capitalize(cattle)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _cropNameController.text = value ?? '';
                  });
                },
                validator: (value) => value == null ? 'Please select a state' : null,
              ),
            ],
            if (_selectedCategory != 'cattle') ...[
              SizedBox(height: 16),
              TextFormField(
                controller: _cropNameController,
                decoration: _buildInputDecoration(
                  capitalize(_currentFieldLabels['cropName'] ?? 'Crop Name'),
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
                    return 'Please enter a cropName';
                  }
                  return null;
                },
              ),
            ],

            SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: _buildInputDecoration(_currentFieldLabels['description']!),
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
                  return 'Please enter a cropName';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneNumberController,
              decoration: _buildInputDecoration('Phone Number'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allows only digits
                LengthLimitingTextInputFormatter(10),  // Limits input to 10 characters
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
            SizedBox(height: 10),
            TextFormField(
              controller: _priceController,
              decoration: _buildInputDecoration(_currentFieldLabels['price']!),
              keyboardType: TextInputType.number,
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
                  return 'Please enter a cropName';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _quantityController,
              decoration: _buildInputDecoration(_currentFieldLabels['quantity']!),
              keyboardType: TextInputType.number,
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
                  return 'Please enter a cropName';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: _buildInputDecoration('State'),
              value: _selectedState,
              items: ['Karnataka', 'Maharashtra'].map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                  _selectedDistrict = null;
                });
              },
              validator: (value) => value == null ? 'Please select a state' : null,
            ),
            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: _buildInputDecoration('District'),
              value: _selectedDistrict,
              items: (_districtsByState[_selectedState] ?? []).map((district) {
                return DropdownMenuItem(value: district, child: Text(district));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                });
              },
              validator: (value) => value == null ? 'Please select a District' : null,
            ),
            SizedBox(height: 10),
            TextFormField(controller: _TalukaController, decoration: _buildInputDecoration('Taluka'),
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
                  return 'Please enter a cropName';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(controller: _villageController, decoration: _buildInputDecoration('Village'),
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
                  return 'Please enter a cropName';
                }
                return null;
              },),
            SizedBox(height: 10),
            TextFormField(
              controller: _pincodeController,
              decoration: _buildInputDecoration('Pincode'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allows only digits
                LengthLimitingTextInputFormatter(6),  // Limits input to 10 characters
              ],
              onChanged: (value) {
                // Clear the error message when the user starts typing
                setState(() {
                  _formKey.currentState!.validate();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Pincode';
                }
                if (value.length != 6) {
                  return 'Pincode must be 6 digits';
                }
                return null;
              },

            ),
            SizedBox(height: 10),

            // Image selection box styled as a text field
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF00AD83)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: Color(0xFF00AD83)),
                    SizedBox(width: 10),
                    Text(
                      _selectedImage == null ? 'Select Image' : 'Image Selected',
                      style: TextStyle(color: Color(0xFF00AD83)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null: _submitMarketPost,
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit',
                  style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00AD83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                // child: Text("Submit",
                //   style: TextStyle(fontSize: 16, color: Colors.white),),
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