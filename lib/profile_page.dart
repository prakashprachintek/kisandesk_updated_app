import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// // Function to store user ID
// Future<void> storeUserId(String userId) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setString('farmer_id', userId);
// }

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  ProfilePage({required this.userData, required this.phoneNumber});

  String _capitalizeName(String fullName) {
    if (fullName == null || fullName.isEmpty) {
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