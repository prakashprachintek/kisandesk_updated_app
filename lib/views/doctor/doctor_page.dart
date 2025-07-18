import 'package:flutter/material.dart';
import '../doctor/doctor.dart';

class DoctorPage extends StatelessWidget {
  DoctorPage({super.key});

  // Dummy data for now
  final List<Doctor> doctors = [
    Doctor(
        name: 'Dr. Priyanka Tewari',
        imageUrl:
            'https://api.dccpets.in/uploads/userprofiles/21087839741649319434.jpeg'),
    Doctor(
        name: 'Dr. Hemant Kumar',
        imageUrl:
            'https://api.dccpets.in/uploads/userprofiles/9439290181649319341.jpeg'),
    Doctor(
        name: 'Dr. Jharna Koul',
        imageUrl:
            'https://api.dccpets.in/uploads/userprofiles/11803321281649319361.jpeg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veterinary Doctors'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        doctor.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Veterinary Specialist",
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
