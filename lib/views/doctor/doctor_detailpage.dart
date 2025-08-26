// doctor_detail_page.dart
import 'package:flutter/material.dart';
import 'doctor.dart';

class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

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
          // Gradient Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00BF8C), Color.fromARGB(255, 13, 148, 46)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          // Doctor Image
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25 -
                80, // Adjust position for better overlap
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
                        blurRadius: 15, // Increased blur for softer shadow
                        offset:
                            Offset(0, 8)), // Increased offset for more depth
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
          // Doctor Details
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25 + 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // More vertical space
                  Center(
                    child: Text(
                      doctor.fullname,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, // Larger font size
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Slightly softer black
                          letterSpacing: 0.2 // Slight letter spacing
                          ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Center(
                    // You might want to add a specialization here if available in Doctor model
                    child: Text(
                      doctor
                          .designation, // Example: Replace with doctor.specialization if you add it
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const Divider(
                      height: 40,
                      thickness: 1.5,
                      indent: 20,
                      endIndent: 20), // Decorative divider

                  detailRow("Phone", doctor.phone, Icons.phone),
                  detailRow("Address", doctor.address, Icons.location_on),
                  detailRow("District", doctor.district, Icons.map),
                  detailRow("Taluka", doctor.taluka, Icons.location_city),
                  detailRow("Village", doctor.village, Icons.home),
                  detailRow("Gender", doctor.gender, Icons.person),
                  detailRow("Status", doctor.status, Icons.info_outline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modified detailRow to include an icon
  static Widget detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 8.0), // Increased vertical padding
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align text to the top if it wraps
        children: [
          Icon(icon, color: Color.fromARGB(255, 0, 0, 0), size: 24), // Green icon
          const SizedBox(width: 12), // Space between icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label:",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Slightly larger label
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(
                    height: 1), // Small space between label and value
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Colors.grey[800], // Darker grey for better readability
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
