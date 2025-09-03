import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../services/user_session.dart';
import 'profileUpdateDialog.dart';

class PersonalDetailsScreen extends StatefulWidget {
  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  Widget _buildInfoItem(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value?.isNotEmpty == true ? value! : '—', // Show dash if empty
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 29, 108, 92),
        title: Text(
          "Personal Details".tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Green Background Gradient
          Container(
            height: 180,
            color: Color.fromARGB(255, 29, 108, 92),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
            ),
          ),

          // Content Area
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width > 360 ? 100 : 80,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image (centered)
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/farmer.png', // Replace with actual image path
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Your Information Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Spreads children across available space
                          children: [
                            Text(
                              "Your Information",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 29, 108, 92),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Color.fromARGB(255, 29, 108, 92),
                                size: 24,
                              ),
                              tooltip: "Edit Profile",
                              onPressed: () async {
                                await profileUpdateDialog(
                                    context, UserSession.user?['phone']);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Reusable Info Item Widget
                        _buildInfoItem("Name", UserSession.user?['full_name']),
                        SizedBox(height: 15),
                        _buildInfoItem("Number", UserSession.user?['phone']),
                        SizedBox(height: 15),
                        _buildInfoItem("DOB", UserSession.user?['dob']),
                        SizedBox(height: 15),
                        _buildInfoItem("Gender", UserSession.user?['gender']),
                        SizedBox(height: 15),
                        _buildInfoItem("Taluq", UserSession.user?['taluka']),
                        SizedBox(height: 15),
                        _buildInfoItem("Village", UserSession.user?['village']),
                        SizedBox(height: 15),
                        _buildInfoItem(
                            "District", UserSession.user?['district']),
                        SizedBox(height: 15),
                        _buildInfoItem("State", UserSession.user?['state']),
                        SizedBox(height: 15),
                        _buildInfoItem("Pincode", UserSession.user?['pincode']),
                        SizedBox(height: 15),
                        _buildInfoItem("Address", UserSession.user?['address']),
                      ],
                    ),
                  ),
                ),
                /*
                SizedBox(height: 15),
                //Edit button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await profileUpdateDialog(
                          context, UserSession.user?['phone']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 29, 108, 92),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Edit Personal Details'.tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                */
              ],
            ),
          ),
        ],
      ),
    );
  }
}
