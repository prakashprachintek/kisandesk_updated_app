
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

  @override
  Widget build(BuildContext context) {
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
                  colors: [Color.fromARGB(255, 19, 77, 61), Color.fromARGB(255, 29, 108, 92)],
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
                  child: Image.asset(
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
          color: isSelected ? const Color.fromARGB(255, 29, 108, 92) : Colors.black54,
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
       // _detailRow("Status", widget.doctor.status, Icons.info_outline),
      ],
    );
  }


  Widget _buildProfessionalDetails() {
    return Column(
      children: [
        _detailRow("Specialization", widget.doctor.designation, Icons.medical_services),
        _detailRow("Status", widget.doctor.status, Icons.info_outline),
        //_detailRow("Experience", "${widget.doctor.experience} years", Icons.star),
      ],
    );
  }


  static Widget _detailRow(String label, String value, IconData icon) {
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      //decoration: TextDecoration.underline,
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
}

Future<void> _launchPhone(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (!await launchUrl(launchUri)) {
    print('Could not launch $launchUri');
  }
}