// doctor_detail_page.dart
import 'package:flutter/material.dart';
import 'doctor.dart';

class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
        //backgroundColor: Colors.transparent,
        //elevation: 0,
        //foregroundColor: Colors.transparent,
        //title: Text(
          //doctor.fullname,
          //style: TextStyle(color: Colors.white),
        //),
      //),
      body: Stack(
        children: [
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
                        blurRadius: 10,
                        offset: Offset(0, 5)),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/doctor_placeholder.png',
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      doctor.fullname,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  detailRow("Phone", doctor.phone),
                  detailRow("Address", doctor.address),
                  detailRow("District", doctor.district),
                  detailRow("Taluka", doctor.taluka),
                  detailRow("Village", doctor.village),
                  detailRow("Gender", doctor.gender),
                  detailRow("Status", doctor.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
