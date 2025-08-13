import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
// Location packages
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocod;

import '../other/coming.dart';
import 'package:mainproject1/views/marketplace/Market_page.dart';

// Adjust these imports for your actual file structure
import '../other/welcome.dart';
import '../profile/profile_page.dart';
import '../other/favoritePage.dart';
import '../mandi/mandiRates.dart';
import '../services/user_session.dart';
import '../whether/whetherinfo.dart';
import '../laborers/LabourRequest.dart';
import '../other/add_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../mandi/mandiService.dart';
import '../doctor/doctor_page.dart';
import '../machinery/machinery_rent_page.dart';

/// A placeholder cart page if you don't have one
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("My Cart")),
      ),
      body: Center(
        child: Text(tr("This is the Cart Page (placeholder).")),
      ),
    );
  }
}

/// ------------------- HOME PAGE --------------------
class HomePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? phoneNumber;

  const HomePage({
    Key? key,
    this.userData,
    this.phoneNumber,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

/// -------------- STATE --------------
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  /// The dynamic location name once fetched, e.g. "Bengaluru, KA"
  String? _locationName;

  String? _profileImageBase64;

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery, // Change to ImageSource.camera if desired
      maxWidth: 600,
      maxHeight: 600,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);
      setState(() {
        _profileImageBase64 = base64Image;
      });
      // Update Firebase with new profile image (assuming userData has 'uid')
      String uid = widget.userData?['uid'] ?? "";
      if (uid.isNotEmpty) {
        FirebaseDatabase.instance.ref("users").child(uid).update({
          'profileImage': base64Image,
        });
      }
    }
  }

  void _showProfileUpdateDialog() {
    // Pre-fill controllers with current user details
    TextEditingController nameController =
        TextEditingController(text: widget.userData?['name'] ?? "");
    TextEditingController emailController =
        TextEditingController(text: widget.userData?['email'] ?? "");
    TextEditingController dobController =
        TextEditingController(text: widget.userData?['dob'] ?? "");
    TextEditingController genderController =
        TextEditingController(text: widget.userData?['gender'] ?? "");
    TextEditingController phoneController =
        TextEditingController(text: widget.userData?['phoneNumber'] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr("Update Profile")),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: tr("Name")),
                ),
                TextField(
                  controller: dobController,
                  decoration:
                      InputDecoration(labelText: tr("DOB (YYYY-MM-DD)")),
                ),
                TextField(
                  controller: genderController,
                  decoration: InputDecoration(labelText: tr("Gender")),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: tr("Mobile Number")),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: tr("Email")),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr("Cancel")),
            ),
            ElevatedButton(
              onPressed: () async {
                String uid = widget.userData?['uid'] ?? "";
                if (uid.isNotEmpty) {
                  await FirebaseDatabase.instance
                      .ref("users")
                      .child(uid)
                      .update({
                    'name': nameController.text,
                    'dob': dobController.text,
                    'gender': genderController.text,
                    'phoneNumber': phoneController.text,
                    'email': emailController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(tr("Profile updated successfully."))));
                }
                Navigator.pop(context);
              },
              child: Text(tr("Update")),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showToastOverlay(context, 'Login Successful. Welcome to Kisan Desk!');
    });
  }

  void showToastOverlay(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height-200,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 238, 238),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    overlay.insert(overlayEntry);

    // Remove after delay
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  /// 1) Determine position using geolocator
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(tr('Location services are disabled.'));
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(tr('Location permissions are denied.'));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        tr('Location permissions are permanently denied, we cannot request permission.'),
      );
    }

    // If all good, get position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// 2) Reverse geocode to city, state
  Future<void> _fetchLocation() async {
    try {
      Position position = await _determinePosition();
      List<geocod.Placemark> placemarks = await geocod.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final city = place.locality ?? tr("Unknown City");
        final state = place.administrativeArea ?? tr("Unknown State");
        final locationStr = "$city, $state";

        setState(() {
          _locationName = locationStr;
        });
      } else {
        setState(() {
          _locationName = tr("Unknown Location");
        });
      }
    } catch (e) {
      setState(() {
        _locationName = tr("Location Error");
      });
      print(tr("Error fetching location: $e"));
    }
  }

  // Tapping avatar => to profile
  void _handleProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          userData: widget.userData ?? {},
          phoneNumber: widget.phoneNumber ?? '',
        ),
      ),
    );
  }

  // removed as per requirement
/*
  // Tapping cart => to a CartPage
  void _handleCartTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartPage()),
    );
  }
*/
  // Bottom nav
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 2) {
      // Navigate to our new dashboard with tabs
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MarketPage(
              // userData: widget.userData ?? {},
              // phoneNumber: widget.phoneNumber ?? '',
              ),
        ),
      );
    } else if (index == 1) {
      // "Add"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddMarketPostPage(
            userData: widget.userData ?? {},
            phoneNumber: widget.phoneNumber ?? '',
            isUserExists: true,
          ),
        ),
      );
    }
  }

  Future<void> _pickProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black54),
                title: Text(tr('Take Photo'),
                    style: TextStyle(color: Colors.black54)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 600,
                    maxHeight: 600,
                  );
                  await _handleProfileImage(pickedFile);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.black54),
                title: Text(tr('Choose from Gallery'),
                    style: TextStyle(color: Colors.black54)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 600,
                    maxHeight: 600,
                  );
                  await _handleProfileImage(pickedFile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleProfileImage(XFile? pickedFile) async {
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("No image selected."))),
      );
      return;
    }
    try {
      File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);
      setState(() {
        _profileImageBase64 = base64Image;
      });
      // Update Firebase (assuming userData has a 'uid' field)
      String uid = widget.userData?['uid'] ?? "";
      if (uid.isNotEmpty) {
        FirebaseDatabase.instance.ref("users").child(uid).update({
          'profileImage': base64Image,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Profile image updated successfully."))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Failed to update image."))),
      );
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.userData?[tr('name')] ?? tr("Guest")),
            accountEmail: Text(widget.userData?[tr('email')] ?? tr("")),
            currentAccountPicture: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileImageBase64 != null &&
                          _profileImageBase64!.isNotEmpty
                      ? MemoryImage(base64Decode(_profileImageBase64!))
                      : AssetImage('assets/profile.jpg') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickProfilePicture, // Use the new method here
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child:
                          Icon(Icons.camera_alt, size: 15, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(tr("Profile")),
            onTap: () {
              Navigator.pop(context);
              _showProfileUpdateDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(tr("Settings")),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Settings page if available.
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_phone),
            title: Text(tr("Inquire")),
            onTap: () {
              Navigator.pop(context);
              // Navigate to an inquiry page or show inquiry dialog.
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text(tr("Help")),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Help page.
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(tr("Version")),
            subtitle: Text(tr("v1.0.0")),
            onTap: () => Navigator.pop(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(tr("Logout")),
            onTap: () async {
              Navigator.pop(context); // Close the drawer first

              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Are you sure you want to log out?"),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancel"),
                      ),
                      SizedBox(
                        height: 1.5,
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("Logout"),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await UserSession.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => KisanDeskScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      // Full-screen gradient behind everything
      body: Stack(
        children: [
          // 1) Gradient from top to bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B5E20), // top dark green
                  Color(0xFF4CAF50),
                  Color(0xFFFFD600), // bottom bright yellow
                ],
                stops: [0.0, 0.4, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2) Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // (a) Top row: user avatar, language dropdown, favorites, cart
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Builder(
                              builder: (context) => IconButton(
                                icon: Icon(Icons.menu,
                                    color: Colors.white, size: 30),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr("KisanDesk"),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      _locationName ?? tr("Fetching...."),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                icon: Image.asset(
                                  'assets/lang.png',
                                  height: 24,
                                  width: 24,
                                  color: Colors.white,
                                ),
                                items: <String>[
                                  'Kannada',
                                  'English',
                                  'Hindi',
                                  'Marathi'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    Locale selectedLocale;
                                    switch (newValue.toLowerCase()) {
                                      case 'kannada':
                                        selectedLocale = Locale('kn');
                                        break;
                                      case 'english':
                                        selectedLocale = Locale('en');
                                        break;
                                      case 'hindi':
                                        selectedLocale = Locale('hi');
                                        break;
                                      case 'marathi':
                                        selectedLocale = Locale('mr');
                                        break;
                                      default:
                                        selectedLocale = Locale('en');
                                    }
                                    context.setLocale(selectedLocale);
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite_border,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FavoritePage(favoriteItems: [])),
                                );
                              },
                            ),
                            /*
                            IconButton(
                              icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
                              onPressed: _handleCartTap,
                            ),
                            */
                          ],
                        ),
                      ],
                    ),
                  ),

                  // (b) Title, location, search
                  /*Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr("KisanDesk"), //updated as told
                          // tr("Farmer Tech Store"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Show location
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              _locationName ?? "Fetching...",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Search bar
                        // Search bar removed as per directed
                        /*
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: tr('Search products...'),
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  SizedBox(height: 16),*/

                  // (c) White container for "body" layout
                  Container(
                    // White background with top corners
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // 0) Mandi Rates Carousel
                          _buildMandiRatesCarousel(),
                          SizedBox(height: 16),

                          // 1) Carousel
                          _buildCarouselSlideshow(),
                          SizedBox(height: 16),

                          // 2) Categories
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              tr('Categories'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildCategoriesGrid(),

                          SizedBox(height: 16),
                          // 3) Deals of the Day
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              tr('Deals of the Day'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildDealsOfDay(),

                          SizedBox(height: 16),
                          // 4) Recommended
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              tr('Recommended'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildRecommendedRow(),

                          // Some bottom padding to avoid overflow behind the bottom nav
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // (d) BOTTOM NAV
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xFF00AD83),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: tr('Home'),
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_sharp),
                label: tr('Market'),
              ),
            ],
          ),
          Positioned(
            top: -24,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      size: 31,
                      color: Color(0xFF00AD83),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    tr('Buy/Sell'),
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// -----------------------------------------
  /// carousel for mandirates
  Widget _buildMandiRatesCarousel() {
    return FutureBuilder<List<MandiRate>>(
      future: fetchTopMandiRates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 110,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: 110,
            child: Center(child: Text(tr("Error loading mandi rates"))),
          );
        }

        final rates = snapshot.data!;
        return CarouselSlider(
          options: CarouselOptions(
            height: 60,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
          ),
          items: rates.map((rate) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MandiRatesPage()),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Green Top Bar
                    /* Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),*/
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Combined Text
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${rate.commodity}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${rate.market}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '₹${rate.maxPrice}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /*
                        Icon(
                          Icons.arrow_upward,
                          color: Color(0xFF00AD83),
                          size: 20,
                        ),
                        */
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// -----------------------------------------
  /// Second Carousel (top slideshow)
  Widget _buildCarouselSlideshow() {
    final List<String> imageUrls = [
      'assets/image2.2.jpg',
      'assets/image1.webp',
      'assets/scrolimage3.jpg',
      'assets/image3.jpg',
    ];

    return Container(
      height: 150,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 150,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 1.0,
        ),
        items: imageUrls.asMap().entries.map((entry) {
          final index = entry.key;
          final url = entry.value;
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MandiRatesPage()),
                    );
                  } else if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherPage(
                          userData: widget.userData ?? {},
                          phoneNumber: widget.phoneNumber ?? '',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  /// -----------------------------------------
  /// 6 Categories Grid
  Widget _buildCategoriesGrid() {
    final List<String> imagePaths = [
      'assets/Labor.jpeg',
      'assets/machines.webp',
      'assets/fertilizers.jpg',
      'assets/veterinary.webp',
      'assets/loan.webp',
      'assets/govtschemes.png',
    ];
    final List<String> labels = [
      tr('Labours'),
      tr('Machinery'),
      tr('Fertilizers'),
      tr('Doctors'),
      tr('Loan/Insurance'),
      tr('Govt Schemes'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: 1 / 1.2,
      ),
      itemBuilder: (context, index) {
        return _CategoryCard(
          imageUrl: imagePaths[index],
          label: labels[index],
          onTap: () => _handleCategoryTap(index),
        );
      },
    );
  }

  /// -----------------------------------------
  /// "Deals of the Day" horizontal slider
  Widget _buildDealsOfDay() {
    final List<_SimpleItem> deals = [
      _SimpleItem(
          title: tr("Fertilizer Combo"),
          price: "\$25",
          image: "assets/pesticide.webp"),
      _SimpleItem(
          title: tr("Bulk Seeds"),
          price: "\$40",
          image: "assets/addatiimage3.jpg"),
      _SimpleItem(
          title: tr("Tractor Tools"),
          price: "\$55",
          image: "assets/machines.webp"),
      _SimpleItem(
          title: tr("Cow Feed"), price: "\$20", image: "assets/cattle.jpg"),
    ];

    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final item = deals[index];
          return GestureDetector(
            onTap: () {
              // If you want to navigate somewhere else
            },
            child: Container(
              width: 130,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      item.image,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 3),
                  Text(
                    item.price,
                    style: TextStyle(color: Colors.green[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// -----------------------------------------
  /// "Recommended" row
  Widget _buildRecommendedRow() {
    final List<_SimpleItem> recommendedItems = [
      _SimpleItem(
          title: tr("Pesticides"),
          price: "\$15",
          image: "assets/pesticide.webp"),
      _SimpleItem(
          title: tr("Seeds"), price: "\$20", image: "assets/addatiimage3.jpg"),
      _SimpleItem(
          title: tr("Harvest Tools"),
          price: "\$35",
          image: "assets/machines.webp"),
      _SimpleItem(
          title: tr("Cattle Feed"), price: "\$10", image: "assets/cattle.jpg"),
    ];

    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedItems.length,
        itemBuilder: (context, index) {
          final item = recommendedItems[index];
          return GestureDetector(
            onTap: () {
              // Open item details or something
            },
            child: Container(
              width: 130,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      item.image,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 3),
                  Text(
                    item.price,
                    style: TextStyle(color: Colors.green[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Category Tapped
  void _handleCategoryTap(int index) {
    if (index == 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              //   builder: (context) => MarketPage(
              //     userData: widget.userData ?? {},
              //     phoneNumber: widget.phoneNumber ?? '',
              //   ),
              // ),
              builder: (context) => LabourRequestPage(
                  userData: widget.userData ?? {}, phoneNumber: "")));
    } else if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MachineryRentPage()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ComingSoonPage()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => DoctorPage()));
    } else if (index == 4) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ComingSoonPage()));
    } else if (index == 5) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ComingSoonPage()));
    }
  }
}

/// A simple card for categories
class _CategoryCard extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;

  const _CategoryCard({
    Key? key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // top image
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            // label
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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

/// A small item model for "Deals"/"Recommended"
class _SimpleItem {
  final String title;
  final String price;
  final String image;

  _SimpleItem({
    required this.title,
    required this.price,
    required this.image,
  });
}
