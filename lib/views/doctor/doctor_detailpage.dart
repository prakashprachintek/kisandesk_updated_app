import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mainproject1/views/doctor/doctor.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  int _selectedTabIndex = 0;

  // This function decodes the base64 string and returns a Uint8List.
  Uint8List? _decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    final commaIndex = base64String.indexOf(',');

    if (commaIndex != -1) {
      base64String = base64String.substring(commaIndex + 1);
    }
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Decode the base64 image data once here
    final Uint8List? imageData = _decodeBase64Image(widget.doctor.image);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 19, 77, 61),
                    Color.fromARGB(255, 29, 108, 92)
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25 - 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageData != null
                      ? Image.memory(
                          imageData,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/doctor_default.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25 + 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      widget.doctor.fullname,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: Text(
                      widget.doctor.designation,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton("Personal Details", 0),
                      _buildTabButton("Professional Details", 1),
                    ],
                  ),
                  const Divider(
                      height: 20, thickness: 1.5, indent: 20, endIndent: 20),
                  _selectedTabIndex == 0
                      ? _buildPersonalDetails()
                      : _buildProfessionalDetails(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? const Color.fromARGB(255, 29, 108, 92)
              : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return Column(
      children: [
        _detailRow("Phone", widget.doctor.phone, Icons.phone),
        _detailRow("Address", widget.doctor.address, Icons.location_on),
        _detailRow("District", widget.doctor.district, Icons.map),
        _detailRow("Taluka", widget.doctor.taluka, Icons.location_city),
        _detailRow("Village", widget.doctor.village, Icons.home),
        _detailRow("Gender", widget.doctor.gender, Icons.person),
      ],
    );
  }

  Widget _buildProfessionalDetails() {
    return Column(
      children: [
        _detailRow("Specialization", widget.doctor.designation,
            Icons.medical_services),
        _detailRow("Status", widget.doctor.status, Icons.info_outline),
      ],
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 0, 0, 0), size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label:",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 1),
                label == "Phone"
                    ? InkWell(
                        onTap: () => _launchPhone(value),
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      print('Could not launch $launchUri');
    }
  }
}