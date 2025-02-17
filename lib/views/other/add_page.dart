import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../home/home_page2.dart';

class AddMarketPostPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  final bool isUserExists; // Add a flag to check if user exists

  AddMarketPostPage({required this.userData, required this.phoneNumber, required this.isUserExists});

  @override
  _AddMarketPostPageState createState() => _AddMarketPostPageState();
}

class _AddMarketPostPageState extends State<AddMarketPostPage> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
 // File? _selectedImage; // Changed to File?
  String? _uploadedFileName;
  File? _selectedImage;
  bool _isUploading = false; // Flag to indicate upload status
  double _uploadProgress = 0.0;



  // Controllers
  final _cropNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _TalukaController = TextEditingController();
  final _villageController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _selectedCategory;

  String? _errorText;

  // State Variables
  Map<String, dynamic> locationData = {};
  List<String> states = [];
  List<String> districts = [];
  List<String> talukas = [];
  List<String> villages = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedTaluka;
  String? selectedVillage;



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
    'crop': {
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
    // 'crop': {
    //   'cropName': 'cropName',
    //   'description': 'description',
    //   'price': 'Price',
    //   'quantity': 'Quantity',
    // },

  };

  Map<String, String> _currentFieldLabels = {
    'cropName': 'Title',
    'description': 'Description',
    'price': 'Price',
    'quantity': 'Quantity',
  };


  final Map<String, List<String>> _districtsByState = {
    'Karnataka': ["Bagalkot", "Ballari", "Belagavi", "Bengaluru Rural", "Bengaluru Urban", "Bidar", "Chamarajanagar", "Chikballapur", "Chikkamagaluru",
      "Chitradurga", "Dakshina Kannada", "Davangere", "Dharwad", "Gadag", "Hassan", "Haveri", "Kalaburagi", "Kodagu", "Kolar", "Koppal", "Mandya",
      "Mysuru", "Raichur", "Ramanagara", "Shivamogga", "Tumakuru", "Udupi", "Uttara Kannada", "Vijayapura", "Yadgir"],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
  };
  @override
  void initState() {
    super.initState();

    // Pre-fill fields from userData

    _TalukaController.text = widget.userData['taluka'] ?? '';
    _villageController.text = widget.userData['village'] ?? '';
    _pincodeController.text = (widget.userData['pincode'] ?? '').toString();
    _phoneNumberController.text = widget.userData['phone'] ?? '';

    // Pre-fill state and district dropdowns if the user exists
    if (widget.isUserExists) {
      selectedState = widget.userData['state'];
      selectedDistrict = widget.userData['district'];
      selectedTaluka = widget.userData['taluka'];
      selectedVillage = widget.userData['village'];
    }
    _updateFieldLabels('farmer'); // Default category
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



  void _updateFieldLabels(String? category) {
    if (category != null && _categoryFieldLabels.containsKey(category)) {
      setState(() {
        _currentFieldLabels = _categoryFieldLabels[category]!;
      });
    }
  }
  // Image Picker function
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Color(0xFF00AD83)),
                  title: Text('Take Picture', style: TextStyle(color: Color(0xFF00AD83))),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                    );
                    await _handleImageSelection(image);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Color(0xFF00AD83)),
                  title: Text('Select from Gallery', style: TextStyle(color: Color(0xFF00AD83))),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                    );
                    await _handleImageSelection(image);
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image.')));
    }
  }

  Future<void> _handleImageSelection(XFile? image) async {
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isUploading = true;
        _uploadProgress = 0.0; // Reset upload progress
      });

      String? fileName = await _uploadImage(File(image.path));
      setState(() {
        _isUploading = false; // End uploading
      });

      if (fileName != null) {
        setState(() => _uploadedFileName = fileName);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploaded successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No image selected.')));
    }
  }
  Future<String?> _uploadImage(File file) async {
    try {
      print('Uploading file: ${file.path}');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://3.110.121.159/api/upload_document'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print('Server Response: $responseData');

      if (response.statusCode == 200) {
        var data = jsonDecode(responseData);
        return data['filename'] ?? file.path.split('/').last;
      } else {
        print('Image Upload Failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }



// Function to submit the market post
  Future<void> _submitMarketPost() async {
    if (_formKey.currentState!.validate()) {
      if (_uploadedFileName == null || _uploadedFileName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload an image first.')),
        );
        return;
      }
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
            "state": selectedState,
            "district": selectedDistrict,
            "taluka": selectedTaluka,
            "village": selectedVillage,
            "pincode": _pincodeController.text,
            "category": _selectedCategory,
            "fileName": _uploadedFileName,
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
                    SizedBox(width: 10), // Reduced spacing between the icon and text
                    Expanded(
                      child: Stack(
                        children: [
                          // Text or Image
                          if (_selectedImage == null)
                            Text(
                              _uploadedFileName == null
                                  ? 'Select Image'
                                  : 'Image Uploaded: $_uploadedFileName',
                              style: TextStyle(color: Color(0xFF00AD83)),
                              overflow: TextOverflow.ellipsis, // Prevents overflow
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),

                          // Circular progress indicator with dynamic completion percentage
                          if (_isUploading)
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 125,
                              child: Align(
                                alignment: Alignment.center, // Center the indicator inside the image
                                child: CircularProgressIndicator(
                                  value: null, // This makes it indeterminate (circulating)
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00AD83)),
                                  backgroundColor: Colors.white.withOpacity(0.8),
                                  strokeWidth: 4.0,
                                ),
                              ),
                            ),
                        ],
                      ),
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

