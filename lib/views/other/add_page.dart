import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mainproject1/views/widgets/api_config.dart';

// Replace this with your actual HomePage widget import
import '../home/HomePage.dart';
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
  // We have 3 steps: 0=Category, 1=Product Details, 2=Location & Submit.
  int _currentStep = 0;

  // Basic fields
  String? _selectedCategory;
  String? _cropName;
  String? _description;
  String? _phoneNumber;
  String? _price;
  String? _quantity;

  // Image stored as Base64 string
  String? _base64Image;

  // Location fields
  bool _useCurrentLocation = false;
  double? _latitude;
  double? _longitude;

  // Manual location data (loaded from JSON)
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

  // Submission flag
  bool _isSubmitting = false;

  // Category-based field labels
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
  };

  // Default field labels
  Map<String, String> _currentFieldLabels = {
    'cropName': 'Title',
    'description': 'Description',
    'price': 'Price',
    'quantity': 'Quantity',
  };

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.userData['phone'] ?? widget.phoneNumber;
    _pincode = (widget.userData['pincode'] ?? '').toString();
    _selectedState = widget.userData['state'];
    _selectedDistrict = widget.userData['district'];
    _selectedTaluka = widget.userData['taluka'];
    _selectedVillage = widget.userData['village'];
    _loadLocationData();
  }

  /// Load location data from JSON file (adjust the path as needed)
  Future<void> _loadLocationData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/loadLocation_data.json');
      final data = json.decode(response);
      setState(() {
        _locationData = data;
        _states = List<String>.from(_locationData['states']);
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
    });
  }

  void updateTalukas(String district) {
    setState(() {
      _selectedTaluka = null;
      _selectedVillage = null;
      _talukas = List<String>.from(_locationData['talukas'][district] ?? []);
      _villages = [];
    });
  }

  void updateVillages(String taluka) {
    setState(() {
      _selectedVillage = null;
      _villages = List<String>.from(_locationData['villages'][taluka] ?? []);
    });
  }

  // Step navigation
  void _handleNext() {
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

  /// STEP 0: Category Selection with Image Cards
  Widget _buildStep0() {
    final Map<String, String> categoryImages = {
      'cattle': 'assets/cattlemm.png',
      'crop': 'assets/cropmm.png',
      'land': 'assets/landmm.png',
      'labour': 'assets/labourm.png',
      'machinery': 'assets/tracm.png',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          physics: NeverScrollableScrollPhysics(),
          children: _categoryFieldLabels.keys.map((cat) {
            final String key = cat.toLowerCase();
            final isSelected = _selectedCategory == key;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = key;
                  _updateFieldLabels(key);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green[100]
                      : const Color.fromARGB(255, 255, 255, 255),
                  border: Border.all(
                    color: isSelected
                        ? Colors.green
                        : const Color.fromARGB(255, 255, 255, 255),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: categoryImages.containsKey(key)
                          ? Image.asset(
                              categoryImages[key]!,
                              fit: BoxFit.contain,
                            )
                          : Icon(Icons.image_not_supported, size: 50),
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
        SizedBox(height: 30),
        _GradientButton(
          text: "Next",
          onPressed: () {
            if (_selectedCategory == null) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Error"),
                  content: Text("Please select a category."),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("OK")),
                  ],
                ),
              );
            } else {
              _handleNext();
            }
          },
        ),
      ],
    );
  }

  /// STEP 1: Enter Product Details
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 30),
        Lottie.asset('assets/animations/onb3.json', height: 200),
        SizedBox(height: 20),
        Center(
          child: Text(
            "Enter Product Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
            labelText: _currentFieldLabels['cropName'] ?? "Title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (val) => _cropName = val,
          initialValue: _cropName,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: _currentFieldLabels['description'] ?? "Description",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (val) => _description = val,
          initialValue: _description,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: "Phone Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (val) => _phoneNumber = val,
          initialValue: _phoneNumber,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: _currentFieldLabels['price'] ?? "Price",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) => _price = val,
          initialValue: _price,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: _currentFieldLabels['quantity'] ?? "Quantity",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) => _quantity = val,
          initialValue: _quantity,
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.black54),
                SizedBox(width: 10),
                Expanded(
                  child: _base64Image == null
                      ? Text(
                          "Select Image",
                          style: TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          "Image selected (Base64)",
                          style: TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _GradientButton(
              text: "Back",
              onPressed: _handleBack,
              gradientColors: [Colors.grey, Colors.grey],
            ),
            _GradientButton(
              text: "Next",
              onPressed: () {
                if ((_cropName == null || _cropName!.isEmpty) ||
                    (_description == null || _description!.isEmpty)) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Error"),
                      content: Text("Please enter product name/description."),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("OK")),
                      ],
                    ),
                  );
                  return;
                }
                _handleNext();
              },
            ),
          ],
        ),
      ],
    );
  }

  /// STEP 2: Location and Submission
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 30),
        Lottie.asset('assets/animations/location.json', height: 180),
        SizedBox(height: 20),
        Center(
          child: Text(
            "Enter Location & Submit",
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
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
            ),
            onChanged: (val) {
              _selectedState = val;
              if (val != null) updateDistricts(val);
            },
            selectedItem: _selectedState,
          ),
          SizedBox(height: 16),
          DropdownSearch<String>(
            items: _districts,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
              ),
            ),
            onChanged: (val) {
              _selectedDistrict = val;
              if (val != null) updateTalukas(val);
            },
            selectedItem: _selectedDistrict,
          ),
          SizedBox(height: 16),
          DropdownSearch<String>(
            items: _talukas,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Taluka',
                border: OutlineInputBorder(),
              ),
            ),
            onChanged: (val) {
              _selectedTaluka = val;
              if (val != null) updateVillages(val);
            },
            selectedItem: _selectedTaluka,
          ),
          SizedBox(height: 16),
          DropdownSearch<String>(
            items: _villages,
            popupProps: PopupProps.menu(showSearchBox: true),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Village',
                border: OutlineInputBorder(),
              ),
            ),
            onChanged: (val) => _selectedVillage = val,
            selectedItem: _selectedVillage,
          ),
          SizedBox(height: 16),
        ],
        TextFormField(
          decoration: InputDecoration(
            labelText: "Pincode",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (val) => _pincode = val,
          initialValue: _pincode,
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _GradientButton(
              text: "Back",
              onPressed: _handleBack,
              gradientColors: [Colors.grey, Colors.grey],
            ),
            _GradientButton(
              text: "Submit",
              onPressed: _isSubmitting ? null : _submitMarketPost,
            ),
          ],
        ),
      ],
    );
  }

  /// Build a toggle button for location selection (Manual vs. Current)
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
            });
            if (_useCurrentLocation) {
              await _fetchCurrentLocation();
            }
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text("Manual"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text("Current"),
            ),
          ],
        ),
      ],
    );
  }

  /// Fetch current location using Geolocator
  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Location Error"),
          content: Text("Location services are disabled."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Permission Denied"),
            content: Text("Location permission is denied."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"))
            ],
          ),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Permission Error"),
          content: Text("Location permission is permanently denied."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
      return;
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Current location: $_latitude, $_longitude")),
    );
  }

  /// Submit post to the specified API
  Future<void> _submitMarketPost() async {
    if (_selectedCategory == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Submission Error"),
          content: Text("Category is missing."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
      return;
    }
    if ((_cropName == null || _cropName!.isEmpty) ||
        (_description == null || _description!.isEmpty)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Submission Error"),
          content: Text("Title/description is missing."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
      return;
    }
    if (_base64Image == null || _base64Image!.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Submission Error"),
          content: Text("Please select an image."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Map<String, dynamic> postData = {
      "farmer_id": UserSession.userId,
      "phoneNumber": _phoneNumber ?? '',
      "cropName": _cropName ?? '',
      "description": _description ?? '',
      "price": int.tryParse(_price ?? '0') ?? 0,
      "quantity": int.tryParse(_quantity ?? '0') ?? 0,
      "state": _selectedState ?? '',
      "district": _selectedDistrict ?? '',
      "taluka": _selectedTaluka ?? '',
      "village": _selectedVillage ?? '',
      "pincode": _pincode ?? '',
      "category": _selectedCategory,
      // "image": _base64Image,
    };

    if (_useCurrentLocation) {
      if (_latitude == null || _longitude == null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Location Error"),
            content: Text("Unable to fetch current location."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"))
            ],
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }
      postData["latitude"] = _latitude;
      postData["longitude"] = _longitude;
    } else {
      postData["state"] = _selectedState;
      postData["district"] = _selectedDistrict;
      postData["taluka"] = _selectedTaluka;
      postData["village"] = _selectedVillage;
      postData["pincode"] = _pincode ?? '';
    }

    try {
      print('❗❗❗postdata :${postData}');
      final response = await http.post(
        Uri.parse('${KD.api}/admin/insert_market_post'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text("Submission Successful"),
            content: Text(
                "Market post added successfully! Redirecting to HomePage..."),
          ),
        );
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
                phoneNumber: widget.phoneNumber, userData: widget.userData),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Submission Error"),
            content: Text("Failed to add post. Status: ${response.statusCode}"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"))
            ],
          ),
        );
      }
    } on SocketException {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Network Error"),
          content: Text("Please check your internet connection."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
    } catch (e) {
      print("Submission error: $e");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Submission Error"),
          content: Text("An unexpected error occurred: $e"),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// Image picking: Convert selected image to Base64
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
                title: Text('Take Picture',
                    style: TextStyle(color: Colors.black54)),
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
                title: Text('Select from Gallery',
                    style: TextStyle(color: Colors.black54)),
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
        SnackBar(content: Text("No image selected.")),
      );
      return;
    }
    try {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      String base64Str = base64Encode(bytes);
      setState(() {
        _base64Image = base64Str;
      });
    } catch (e) {
      print("Error reading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to convert image.")),
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
        title: Text("Add Market Post (Step ${_currentStep + 1}/3)"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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

/// A gradient button widget
class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;

  const _GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [
      Color(0xFF1B5E20),
      Color(0xFFFFD600),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final colors = isEnabled ? gradientColors : [Colors.grey, Colors.grey];

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
