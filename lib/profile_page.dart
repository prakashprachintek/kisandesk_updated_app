import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mainproject1/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mandiRates.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  ProfilePage({required this.userData, required this.phoneNumber});


  String _capitalizeName(String fullName) {
    if (fullName.isEmpty) {
      return '';
    }
    List<String> nameParts = fullName.split(' ');
    List<String> capitalizedParts = nameParts.map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).toList();
    return capitalizedParts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Text(tr('Profile')),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Implement sharing functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            SizedBox(height: 16),
            Text(
              _capitalizeName(userData['full_name']),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00AD83),
              ),
            ),
            SizedBox(height: 8),
            Text(
              userData['phone']?.toString() ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionWithDivider(
                    context,
                    icon: Icons.settings,
                    title: 'Profile Setting',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileSettingPage(
                                userData: userData,
                                phoneNumber: phoneNumber,
                              ),
                        ),
                      );
                    },
                  ),
                  _buildSectionWithDivider(
                    context,
                    icon: Icons.account_balance,
                    title: 'Government Scheme',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GovernmentSchemePage(),
                        ),
                      );
                    },
                  ),
                  _buildSectionWithDivider(
                    context,
                    icon: Icons.work,
                    title: 'Mandi Rate',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MandiRatesPage(),
                        ),
                      );
                    },
                  ),
                  _buildSectionWithDivider(
                    context,
                    icon: Icons.delete_forever,
                    title: 'Account Delete',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountDeletePage(),
                        ),
                      );
                    },
                  ),
                  _buildSectionWithDivider(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithDivider(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Color(0xFF00AD83)),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(thickness: 1.0, color: Colors.grey[300]),
        SizedBox(height: 8), // Adjust spacing as needed
      ],
    );
  }
}

// Placeholder pages for navigation
class ProfileSettingPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  ProfileSettingPage({required this.userData, required this.phoneNumber});

  String _capitalizeName(String fullName) {
    if (fullName.isEmpty) {
      return '';
    }

    // Split the name into parts (first name, surname, etc.)
    List<String> nameParts = fullName.split(' ');

    // Capitalize the first letter of each part
    List<String> capitalizedParts = nameParts.map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).toList();

    // Join the parts back together
    return capitalizedParts.join(' ');
  }

  // Function to store user ID
  Future<void> storeUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_id', userId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Text(tr('Profile')),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // _shareProfile();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your profile image path
            ),
            SizedBox(height: 16),
            Text(
              _capitalizeName(userData['full_name']),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00AD83),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${userData['phone']?.toString()}', // Convert to String if necessary
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Color(0xFF00AD83)),
                    title: Text(tr('Full Name')),
                    subtitle: Text(tr('${userData['full_name']}')),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: Color(0xFF00AD83)),
                    title: Text(tr('Phone Number')),
                    subtitle: Text('${userData['phone']?.toString()}'), // Convert to String if necessary
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city, color: Color(0xFF00AD83)),
                    title: Text(tr('Address')),
                    subtitle: Text(tr('${userData['address']?.toString()}')), // Convert to String if necessary
                  ),
                  ListTile(
                    leading: Icon(Icons.person_pin_circle_outlined, color: Color(0xFF00AD83)),
                    title: Text(tr('Pincode')),
                    subtitle: Text('${userData['pincode']?.toString()}'), // Convert to String if necessary
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city_outlined, color: Color(0xFF00AD83)),
                    title: Text(tr('District')),
                    subtitle: Text('${userData['district']?.toString()}'), // Convert to String if necessary
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city_outlined, color: Color(0xFF00AD83)),
                    title: Text(tr('Taluka')),
                    subtitle: Text('${userData['taluka']?.toString()}'), // Convert to String if necessary
                  ),
                  ListTile(
                    leading: Icon(Icons.home_filled, color: Color(0xFF00AD83)),
                    title: Text(tr('Village')),
                    subtitle: Text(tr('${userData['village']?.toString()}')), // Convert to String if necessary
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GovernmentSchemePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Text('Government Scheme'),
      ),
      body: Center(
        child: Text('Government scheme details go here.'),
      ),
    );
  }
}

class AgricultureJobPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Text('Agriculture Job Posts'),
      ),
      body: Center(
        child: Text('mandi rates'),
      ),
    );
  }
}

class AccountDeletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Text('Account Delete'),
      ),
      body: Center(
        child: Text('Account deletion details go here.'),
      ),
    );
  }
}
