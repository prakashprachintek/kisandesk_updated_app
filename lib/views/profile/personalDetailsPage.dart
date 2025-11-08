import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/profile/profile_update_page.dart';
import 'package:mainproject1/views/profile/uploadImageDialog.dart';

import '../services/api_config.dart';
import '../services/user_session.dart';

class PersonalDetailsScreen extends StatefulWidget {
  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  String? _profilePicUrl;
  bool _isLoadingPic = true;

  // -----------------------------------------------------------------
  // Fetch Profile Pic
  // -----------------------------------------------------------------
  Future<void> _fetchProfilePic() async {
    final userId = UserSession.userId;
    if (userId == null) {
      setState(() => _isLoadingPic = false);
      return;
    }

    setState(() => _isLoadingPic = true);

    try {
      final response = await http.post(
        Uri.parse('${KD.api}/user/get_profile_pic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        setState(() => _isLoadingPic = false);
        return;
      }

      final json = jsonDecode(response.body);
      final String? imageUrl = json['profile_url']?.toString().trim();

      setState(() {
        _profilePicUrl = imageUrl;
        _isLoadingPic = false;
      });
    } catch (e) {
      setState(() => _isLoadingPic = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfilePic();
  }

  // -----------------------------------------------------------------
  // Info Row
  // -----------------------------------------------------------------
  Widget _buildInfoItem(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value?.isNotEmpty == true ? value! : '—',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------
  // Profile Picture
  // -----------------------------------------------------------------
  Widget _buildProfilePicture() {
    if (_isLoadingPic) {
      return SizedBox(
        width: 150,
        height: 150,
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 29, 108, 92),
          strokeWidth: 3,
        ),
      );
    }

    if (_profilePicUrl != null) {
      return Image.network(
        _profilePicUrl!,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
        loadingBuilder: (context, child, progress) {
          return progress == null
              ? child
              : Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes!)
                        : null,
                    color: Color.fromARGB(255, 29, 108, 92),
                  ),
                );
        },
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() => Image.asset(
        'assets/farmer.png',
        fit: BoxFit.cover,
        width: 150,
        height: 150,
      );

  // -----------------------------------------------------------------
  // Show SnackBar (Success / Error)
  // -----------------------------------------------------------------
  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: isSuccess ? Duration(seconds: 2) : Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -----------------------------------------------------------------
  // Main UI
  // -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
        title: Text(
          "Personal Details".tr(),
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfilePic,
        child: Stack(
          children: [
            Container(height: 140, color: const Color.fromARGB(255, 29, 108, 92)),

            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width > 360 ? 40 : 80,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------- PROFILE IMAGE -------------------
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, spreadRadius: 2),
                            ],
                          ),
                          child: ClipOval(child: _buildProfilePicture()),
                        ),

                        // Edit Pencil
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              final result = await uploadImageDialog(
                                context: context,
                                userId: UserSession.user?["_id"],
                              );

                              // Handle upload result
                              if (result != null) {
                                if (result['success'] == true) {
                                  _showSnackBar("Success", isSuccess: true);
                                  _fetchProfilePic(); // Refresh image
                                } else {
                                  final msg = result['message'] ?? 'Upload failed';
                                  _showSnackBar(msg, isSuccess: false);
                                }
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 29, 108, 92),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------- YOUR INFORMATION -------------------
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                icon: Icon(Icons.edit, color: Color.fromARGB(255, 29, 108, 92), size: 24),
                                tooltip: "Edit Profile",
                                onPressed: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProfileUpdatePage(
                                        phone: UserSession.user?['phone'] ?? '',
                                        onSuccess: () => setState(() {}),
                                      ),
                                    ),
                                  );
                                  if (result == true) setState(() {});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoItem("Name", UserSession.user?['full_name']),
                          const SizedBox(height: 15),
                          _buildInfoItem("Number", UserSession.user?['phone']),
                          const SizedBox(height: 15),
                          _buildInfoItem("DOB", UserSession.user?['dob']),
                          const SizedBox(height: 15),
                          _buildInfoItem("Gender", UserSession.user?['gender']),
                          const SizedBox(height: 15),
                          _buildInfoItem("Taluq", UserSession.user?['taluka']),
                          const SizedBox(height: 15),
                          _buildInfoItem("Village", UserSession.user?['village']),
                          const SizedBox(height: 15),
                          _buildInfoItem("District", UserSession.user?['district']),
                          const SizedBox(height: 15),
                          _buildInfoItem("State", UserSession.user?['state']),
                          const SizedBox(height: 15),
                          _buildInfoItem("Pincode", UserSession.user?['pincode']),
                          const SizedBox(height: 15),
                          _buildInfoItem("Address", UserSession.user?['address']),
                        ],
                      ),
                    ),
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