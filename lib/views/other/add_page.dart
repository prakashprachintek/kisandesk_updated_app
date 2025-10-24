import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mainproject1/views/marketplace/Market_page.dart';
import 'package:mainproject1/views/services/api_config.dart';
import '../services/user_session.dart';

class AddMarketPostPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  final bool isUserExists;

  const AddMarketPostPage({
    Key? key,
    required this.userData,
    required this.phoneNumber,
    required this.isUserExists,
  }) : super(key: key);

  @override
  _AddMarketPostPageState createState() => _AddMarketPostPageState();
}

class _AddMarketPostPageState extends State<AddMarketPostPage> {
  int _currentStep = 0;
  String? _selectedCategory;
  String? _cropName;
  String? _description;
  String? _phoneNumber;
  String? _price;
  String? _quantity;
  String? _base64Image;
  String? _fileName;
  bool _useCurrentLocation = false;
  double? _latitude;
  double? _longitude;
  Map<String, dynamic> _locationData = {};
  List<String> _states = [];
  List<String> _districts = [];
  List<String> _talukas = [];
  List<String> _villages = [];
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String? _selectedVillage;
  String? _pincode;
  bool _isSubmitting = false;
  bool _hasSubmitted = false; // Track submission attempt
  final _formKey = GlobalKey<FormState>();

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
    'machinery': {
      'cropName': 'Machine Name',
      'description': 'Machine Description',
      'price': 'Price',
      'quantity': 'Quantity Available',
    },
  };

  final Map<String, List<Map<String, String>>> _categoryOptions = {
    'cattle': [
      {'name': 'Cow', 'image': 'assets/cow.png'},
      {'name': 'Ox', 'image': 'assets/oxnew.jpg'},
      {'name': 'Buffalo', 'image': 'assets/Buffalom.png'},
      {'name': 'Sheep', 'image': 'assets/Sheep.png'},
      {'name': 'Goat', 'image': 'assets/goat (2).png'},
      {'name': 'Hen', 'image': 'assets/Henm.png'},
      {'name': 'Duck', 'image': 'assets/Duck.png'},
    ],
    'crop': [
      {'name': 'Pulses', 'image': 'assets/pulses.png'},
      {'name': 'Oil Seeds', 'image': 'assets/oil_seedsm.png'},
      {'name': 'Fruits', 'image': 'assets/fruitsm.png'},
      {'name': 'Vegetables', 'image': 'assets/vegetablesm.png'},
      {'name': 'Cereals', 'image': 'assets/cerealsm.png'},
      {'name': 'Dry Fruits', 'image': 'assets/dryfruitsm.png'}
    ],
    'land': [
      {'name': 'Home', 'image': 'assets/house.jpg'},
      {'name': 'Plots', 'image': 'assets/Plots.png'},
      {'name': 'Dry Land', 'image': 'assets/DryLand.png'},
      {'name': 'Irrigation Land', 'image': 'assets/irrigationland.png'}
    ],
    'machinery': [
      {'name': 'Transport Vehicles', 'image': 'assets/Transportm.png'},
      {'name': 'Farming Machines', 'image': 'assets/FarmingMachine.png'},
      {'name': 'Farming Equipment', 'image': 'assets/FarmingEqui.png'},
    ],
  };

  final Map<String, List<String>> _quantityOptions = {
    'cattle': ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10+'],
    'land': [
      '1 Acre',
      '2 Acres',
      '3 Acres',
      '4 Acres',
      '5 Acres',
      '6 Acres',
      '7 Acres',
      '8 Acres',
      '9 Acres',
      '10 Acres',
      'More than 10 Acres'
    ],
    'machinery': [
      '1 Unit',
      '2 Units',
      '3 Units',
      '4 Units',
      '5 Units',
      '6 Units',
      '7 Units',
      '8 Units',
      '9 Units',
      '10 Units',
      'More than 10 Units'
    ],
    'crop': [
      '10 Kg',
      '20 Kg',
      '30 Kg',
      '40 Kg',
      '50 Kg',
      '60 Kg',
      '70 Kg',
      '80 Kg',
      '90 Kg',
      '100 kg',
      'More than 100 Kg'
    ],
  };

  Map<String, String> _currentFieldLabels = {
    'cropName': 'Title',
    'description': 'Description',
    'price': 'Price',
    'quantity': 'Quantity',
  };

  @override
  void initState() {
    super.initState();
    final user = UserSession.user ?? {};
    _phoneNumber = user['phone'] ?? widget.phoneNumber;
    _pincode = (user['pincode'] ?? '').toString();
    _selectedState = user['state'];
    _selectedDistrict = user['district'];
    _selectedTaluka = user['taluka'];
    _selectedVillage = user['village'];
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      final String response = await rootBundle.loadString('assets/loadLocation_data.json');
      final data = json.decode(response);
      setState(() {
        _locationData = data;
        _states = List<String>.from(_locationData['states']);
        if (_selectedState != null) {
          _districts = List<String>.from(_locationData['districts'][_selectedState] ?? []);
          if (_selectedDistrict != null) {
            _talukas = List<String>.from(_locationData['talukas'][_selectedDistrict] ?? []);
            if (_selectedTaluka != null) {
              _villages = List<String>.from(_locationData['villages'][_selectedTaluka] ?? []);
            }
          }
        }
      });
    } catch (e) {
      print("Failed to load location data: $e");
    }
  }

  void updateDistricts(String state) {
    setState(() {
      _selectedDistrict = null;
      _selectedTaluka = null;
      _selectedVillage = null;
      _districts = List<String>.from(_locationData['districts'][state] ?? []);
      _talukas = [];
      _villages = [];
      if (_hasSubmitted) {
        _formKey.currentState!.validate();
      }
    });
  }

  void updateTalukas(String district) {
    setState(() {
      _selectedTaluka = null;
      _selectedVillage = null;
      _talukas = List<String>.from(_locationData['talukas'][district] ?? []);
      _villages = [];
      if (_hasSubmitted) {
        _formKey.currentState!.validate();
      }
    });
  }

  void updateVillages(String taluka) {
    setState(() {
      _selectedVillage = null;
      _villages = List<String>.from(_locationData['villages'][taluka] ?? []);
      if (_hasSubmitted) {
        _formKey.currentState!.validate();
      }
    });
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("Please select a category"))),
        );
        return;
      }
      _updateFieldLabels(_selectedCategory);
    } else if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) {
        setState(() => _hasSubmitted = true);
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _updateFieldLabels(String? cat) {
    if (cat != null && _categoryFieldLabels.containsKey(cat)) {
      setState(() {
        _currentFieldLabels = _categoryFieldLabels[cat]!;
      });
    }
  }

  bool isFormValid() {
    return _selectedCategory != null &&
        _cropName != null &&
        _cropName!.isNotEmpty &&
        _description != null &&
        _description!.isNotEmpty &&
        _phoneNumber != null &&
        _phoneNumber!.length == 10 &&
        _price != null &&
        _price!.isNotEmpty &&
        (_quantity != null || _selectedCategory == 'machinery') &&
        _quantity!.isNotEmpty &&
        _base64Image != null &&
        _base64Image!.isNotEmpty &&
        (_useCurrentLocation
            ? (_latitude != null && _longitude != null)
            : (_selectedState != null &&
                _selectedDistrict != null &&
                _selectedTaluka != null &&
                _selectedVillage != null &&
                _pincode != null &&
                _pincode!.length == 6));
  }

  Widget _buildStep0() {
    final Map<String, String> categoryImages = {
      'cattle': 'assets/cattlen.png',
      'crop': 'assets/cropn.png',
      'land': 'assets/propn.jpg',
      'machinery': 'assets/Machinen.png',
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 450,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _categoryFieldLabels.keys.map((cat) {
                final String key = cat.toLowerCase();
                final isSelected = _selectedCategory == key;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = key;
                      _updateFieldLabels(key);
                      _cropName = null;
                      _description = null;
                      _price = null;
                      _quantity = null;
                    });
                    _handleNext();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[100] : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.white,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 80,
                          child: categoryImages.containsKey(key)
                              ? Image.asset(categoryImages[key]!, fit: BoxFit.contain)
                              : Icon(Icons.image_not_supported, size: 160),
                        ),
                        SizedBox(height: 10),
                        Text(
                          key[0].toUpperCase() + key.substring(1),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final List<Map<String, String>> currentOptions = _categoryOptions[_selectedCategory!] ?? [];

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownSearch<String>(
              items: currentOptions.map((e) => e['name']!).toList(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: tr(_currentFieldLabels['cropName'] ?? "Title"),
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _cropName = val;
                  if (_hasSubmitted) {
                    _formKey.currentState!.validate();
                  }
                });
              },
              selectedItem: _cropName,
              validator: (value) => value == null ? tr('Please select a title') : null,
              popupProps: PopupProps.menu(
                showSearchBox: false,
                constraints: const BoxConstraints(maxHeight: 400),
                menuProps: MenuProps(
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                ),
                itemBuilder: (context, item, isSelected) {
                  final option = currentOptions.firstWhere(
                    (e) => e['name'] == item,
                    orElse: () => {'name': item, 'image': 'assets/default.png'},
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: isSelected ? Colors.green[50] : null,
                    child: Row(
                      children: [
                        Image.asset(
                          option['image']!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 30),
                        ),
                        SizedBox(width: 10),
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: tr(_currentFieldLabels['description'] ?? "Description"),
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (val) {
                _description = val;
                if (_hasSubmitted) {
                  _formKey.currentState!.validate();
                }
                setState(() {});
              },
              initialValue: _description,
              validator: (value) => value == null || value.trim().isEmpty ? tr('Please enter a description') : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: tr("Phone Number"),
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (val) {
                _phoneNumber = val;
                if (_hasSubmitted) {
                  _formKey.currentState!.validate();
                }
                setState(() {});
              },
              initialValue: _phoneNumber,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return tr('Please enter a phone number');
                }
                if (value.length != 10) {
                  return tr('Phone number must be 10 digits');
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: tr(_currentFieldLabels['price'] ?? "Price"),
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _price = val;
                if (_hasSubmitted) {
                  _formKey.currentState!.validate();
                }
                setState(() {});
              },
              initialValue: _price,
              validator: (value) => value == null || value.trim().isEmpty ? tr('Please enter a price') : null,
            ),
            SizedBox(height: 16),
            if (_selectedCategory != 'machinery') ...[
              if (_quantityOptions.containsKey(_selectedCategory))
                DropdownSearch<String>(
                  items: _quantityOptions[_selectedCategory] ?? [],
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: tr(_currentFieldLabels['quantity'] ?? "Quantity"),
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _quantity = val;
                      if (_hasSubmitted) {
                        _formKey.currentState!.validate();
                      }
                    });
                  },
                  selectedItem: _quantity,
                  validator: (value) => value == null ? tr('Please select a quantity') : null,
                  popupProps: PopupProps.menu(
                    showSearchBox: false,
                    menuProps: MenuProps(
                      borderRadius: BorderRadius.circular(8),
                      elevation: 4,
                    ),
                  ),
                )
              else
                TextFormField(
                  decoration: InputDecoration(
                    labelText: tr(_currentFieldLabels['quantity'] ?? "Quantity"),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    _quantity = val;
                    if (_hasSubmitted) {
                      _formKey.currentState!.validate();
                    }
                    setState(() {});
                  },
                  initialValue: _quantity,
                  validator: (value) => value == null || value.trim().isEmpty ? tr('Please enter a quantity') : null,
                ),
              SizedBox(height: 16),
            ],
            GestureDetector(
              onTap: _base64Image == null ? _pickImage : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _hasSubmitted && _base64Image == null ? Colors.red : Colors.grey.shade400,
                    width: _hasSubmitted && _base64Image == null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt,
                        color: _hasSubmitted && _base64Image == null ? Colors.red : Colors.grey.shade400),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _base64Image == null
                            ? tr("Upload Image")
                            : tr("Image selected: ${_fileName ?? 'Base64'}"),
                        style: TextStyle(
                          color: _hasSubmitted && _base64Image == null ? Colors.red : Colors.grey.shade400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_base64Image != null)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          setState(() {
                            _base64Image = null;
                            _fileName = null;
                            if (_hasSubmitted) {
                              _formKey.currentState!.validate();
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_hasSubmitted && _base64Image == null)
              Padding(
                padding: EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  tr('Please upload an image'),
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GradientButton(
                  text: tr("Back"),
                  onPressed: _handleBack,
                  gradientColors: [Colors.grey, Colors.grey],
                ),
                _GradientButton(
                  text: tr("Next"),
                  onPressed: _handleNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Lottie.asset('assets/animations/location.json', height: 180),
            SizedBox(height: 10),
            Center(
              child: Text(
                tr("Enter Location & Submit"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildLocationToggle(),
            SizedBox(height: 16),
            if (!_useCurrentLocation) ...[
              DropdownSearch<String>(
                items: _states,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: tr('State'),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedState = val;
                    if (val != null) updateDistricts(val);
                    if (_hasSubmitted) {
                      _formKey.currentState!.validate();
                    }
                  });
                },
                selectedItem: _selectedState,
                validator: (value) => !_useCurrentLocation && value == null ? tr('Please select a state') : null,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.circular(8),
                    elevation: 4,
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownSearch<String>(
                items: _districts,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: tr('District'),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedDistrict = val;
                    if (val != null) updateTalukas(val);
                    if (_hasSubmitted) {
                      _formKey.currentState!.validate();
                    }
                  });
                },
                selectedItem: _selectedDistrict,
                validator: (value) =>
                    !_useCurrentLocation && _selectedState != null && value == null ? tr('Please select a district') : null,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.circular(8),
                    elevation: 4,
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownSearch<String>(
                items: _talukas,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: tr('Taluka'),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedTaluka = val;
                    if (val != null) updateVillages(val);
                    if (_hasSubmitted) {
                      _formKey.currentState!.validate();
                    }
                  });
                },
                selectedItem: _selectedTaluka,
                validator: (value) => !_useCurrentLocation && _selectedDistrict != null && value == null
                    ? tr('Please select a taluka')
                    : null,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.circular(8),
                    elevation: 4,
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownSearch<String>(
                items: _villages,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: tr('Village'),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedVillage = val;
                    if (_hasSubmitted) {
                      _formKey.currentState!.validate();
                    }
                  });
                },
                selectedItem: _selectedVillage,
                validator: (value) => !_useCurrentLocation && _selectedTaluka != null && value == null
                    ? tr('Please select a village')
                    : null,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.circular(8),
                    elevation: 4,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: tr("Pincode"),
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (val) {
                  _pincode = val;
                  if (_hasSubmitted) {
                    _formKey.currentState!.validate();
                  }
                  setState(() {});
                },
                initialValue: _pincode,
                validator: (value) {
                  if (!_useCurrentLocation) {
                    if (value == null || value.trim().isEmpty) {
                      return tr('Please enter a pincode');
                    }
                    if (value.length != 6) {
                      return tr('Pincode must be 6 digits');
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GradientButton(
                  text: tr("Back"),
                  onPressed: _handleBack,
                  gradientColors: [Colors.grey, Colors.grey],
                ),
                _GradientButton(
                  text: tr("Submit"),
                  onPressed: _submitMarketPost,
                  gradientColors: isFormValid()
                      ? [Color.fromARGB(255, 29, 108, 92), Color.fromARGB(255, 29, 108, 92)]
                      : [Colors.grey[400]!, Colors.grey[400]!],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          isSelected: [!_useCurrentLocation, _useCurrentLocation],
          onPressed: (index) async {
            setState(() {
              if (index == 0) {
                _useCurrentLocation = false;
                _latitude = null;
                _longitude = null;
              } else {
                _useCurrentLocation = true;
              }
              if (_hasSubmitted) {
                _formKey.currentState!.validate();
              }
            });
            if (_useCurrentLocation) {
              await _fetchCurrentLocation();
            }
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(tr("Manual")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(tr("Current")),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Location services are disabled"))),
      );
      setState(() => _useCurrentLocation = false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("Location permission is denied"))),
        );
        setState(() => _useCurrentLocation = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Location permission is permanently denied"))),
      );
      setState(() => _useCurrentLocation = false);
      return;
    }
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr("Current location: $_latitude, $_longitude"))),
    );
  }

  Future<void> _submitMarketPost() async {
    setState(() => _hasSubmitted = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = false);
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Please select a category"))),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    if (_useCurrentLocation && (_latitude == null || _longitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Unable to fetch current location"))),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Upload the image with retry
      bool imageUploaded = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        var imageRequest = http.MultipartRequest(
          'POST',
          Uri.parse('${KD.api}/upload_document'),
        );
        imageRequest.files.add(
          http.MultipartFile.fromBytes(
            'file',
            base64Decode(_base64Image!),
            filename: _fileName,
          ),
        );

        var imageResponse = await imageRequest.send();
        final responseData = jsonDecode(await imageResponse.stream.bytesToString());

        if (imageResponse.statusCode == 200 || imageResponse.statusCode == 201) {
          if (responseData['message'] == 'File uploaded successfully') {
            imageUploaded = true;
            break;
          }
        }

        if (attempt < 3) {
          await Future.delayed(Duration(milliseconds: 500));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr("Failed to upload image: ${responseData['message'] ?? 'Status ${imageResponse.statusCode}'}"),
              ),
            ),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }

      if (!imageUploaded) return;

      // Step 2: Immediately call the insert market post API
      Map<String, dynamic> postData = {
        "farmer_id": UserSession.userId,
        "phoneNumber": _phoneNumber ?? '',
        "cropName": _cropName ?? '',
        "description": _description ?? '',
        "price": int.tryParse(_price ?? '0') ?? 0,
        "quantity": int.tryParse(_quantity?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0,
        "state": _selectedState ?? '',
        "district": _selectedDistrict ?? '',
        "taluka": _selectedTaluka ?? '',
        "village": _selectedVillage ?? '',
        "pincode": _pincode ?? '',
        "category": _selectedCategory,
        "fileName": _fileName,
      };

      if (_useCurrentLocation) {
        postData["latitude"] = _latitude;
        postData["longitude"] = _longitude;
      }

      // Retry for market post API
      bool postCreated = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        final postResponse = await http.post(
          Uri.parse('${KD.api}/admin/insert_market_post'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(postData),
        );

        if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
          postCreated = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: Text(tr("Submission Successful")),
              content: Text(tr("Market Post Initiated Successfully. Redirecting to Marketplace...")),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MarketPage()),
                    );
                  },
                  child: Text(tr("OK")),
                ),
              ],
            ),
          );
          break;
        }

        if (attempt < 3) {
          await Future.delayed(Duration(milliseconds: 500));
        } else {
          final responseData = jsonDecode(postResponse.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr("Failed to add post: ${responseData['message'] ?? 'Status ${postResponse.statusCode}'}"),
              ),
            ),
          );
        }
      }

      if (!postCreated) {
        setState(() => _isSubmitting = false);
        return;
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Please check your internet connection"))),
      );
    } catch (e) {
      print("Submission error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("An unexpected error occurred: $e"))),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black54),
                title: Text(tr('Take Picture'), style: TextStyle(color: Colors.black54)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  await _handleImageSelection(pickedFile);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.black54),
                title: Text(tr('Select from Gallery'), style: TextStyle(color: Colors.black54)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  await _handleImageSelection(pickedFile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleImageSelection(XFile? pickedFile) async {
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("No image selected"))),
      );
      return;
    }
    try {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      String base64Str = base64Encode(bytes);
      setState(() {
        _base64Image = base64Str;
        _fileName = pickedFile.name;
        if (_hasSubmitted) {
          _formKey.currentState!.validate();
        }
      });
    } catch (e) {
      print("Error reading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Failed to convert image"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget stepWidget;
    if (_currentStep == 0) {
      stepWidget = _buildStep0();
    } else if (_currentStep == 1) {
      stepWidget = _buildStep1();
    } else {
      stepWidget = _buildStep2();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Add Market Post (Step ${_currentStep + 1}/3)")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: EdgeInsets.all(16),
          child: stepWidget,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;

  const _GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [Color.fromARGB(255, 29, 108, 92), Color.fromARGB(255, 29, 108, 92)],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final colors = isEnabled ? gradientColors : [Colors.grey[400]!, Colors.grey[400]!];

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}