import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mainproject1/views/doctor/doctor.dart';
import 'package:mainproject1/views/services/AppAssets.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  int _selectedTabIndex = 0;

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

  static Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      print('Could not launch $launchUri');
    }
  }


  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTabIndex == index;
    const primaryColor = Color.fromARGB(255, 29, 108, 92);
    
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), 
      ),
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
          color: isSelected ? primaryColor : Colors.black54,
        ),
      ),
    );
  }


  Widget _buildPersonalDetails() {
    const verticalGap = SizedBox(height: 18); 
    const detailItemPadding = EdgeInsets.symmetric(horizontal: 5.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: detailItemPadding,
                child: _detailItem("Phone", widget.doctor.phone, Icons.phone, isPhone: true),
              ),
            ),
            Expanded(
              child: Padding(
                padding: detailItemPadding,
                child: _detailItem("Gender", widget.doctor.gender, Icons.person),
              ),
            ),
          ],
        ),
        
        verticalGap,

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: detailItemPadding,
                child: _detailItem("District", widget.doctor.district, Icons.map),
              ),
            ),
            Expanded(
              child: Padding(
                padding: detailItemPadding,
                child: _detailItem("Taluka", widget.doctor.taluka, Icons.location_city),
              ),
            ),
          ],
        ),
        
        verticalGap,

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: detailItemPadding,
                child: _detailItem("Village", widget.doctor.village, Icons.home),
              ),
            ),
            Expanded(
              child: Padding(
                padding: detailItemPadding,
                child: _detailItem("Address", widget.doctor.address, Icons.location_on),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalDetails() {
    const detailItemPadding = EdgeInsets.symmetric(horizontal: 5.0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: detailItemPadding,
            child: _detailItem("Specialization", widget.doctor.designation, Icons.medical_services),
          ),
        ),
        Expanded(
          child: Padding(
            padding: detailItemPadding,
            child: _detailItem("Status", widget.doctor.status, Icons.info_outline),
          ),
        ),
      ],
    );
  }


  Widget _detailItem(String label, String value, IconData icon, {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black54, size: 18), 
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        isPhone
            ? InkWell(
                onTap: () => _launchPhone(value),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final Uint8List? imageData = _decodeBase64Image(widget.doctor.image);
    const mainContentPadding = EdgeInsets.symmetric(horizontal: 24.0); 

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
                      : Image.asset(AppAssets.doctorDefault, 
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
              padding: const EdgeInsets.only(top: 24.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: mainContentPadding,
                    child: Center(
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
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: mainContentPadding,
                    child: Center(
                      child: Text(
                        widget.doctor.designation,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
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
                  Padding(
                    padding: mainContentPadding,
                    child: _selectedTabIndex == 0
                        ? _buildPersonalDetails()
                        : _buildProfessionalDetails(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}