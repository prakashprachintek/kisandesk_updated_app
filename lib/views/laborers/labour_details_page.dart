import 'package:flutter/material.dart';

class LabourDetailsPage extends StatelessWidget {
  final Map labour;

  const LabourDetailsPage({Key? key, required this.labour}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E6F5C),
                      Color(0xFF2E7D67),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),

              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Positioned(
                bottom: -50,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.red,
                    child: Text(
                      labour["full_name"]
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          Text(
            labour["full_name"] ?? "",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            labour["work_category"] ?? "",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xFF2E7D67),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF2E7D67),
                    tabs: [
                      Tab(text: "Personal Details"),
                      Tab(text: "Professional Details"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPersonalDetails(),
                        _buildProfessionalDetails(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Personal Details
  Widget _buildPersonalDetails() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPhoneRow(labour["phone"]),
          _infoRow(Icons.person, "Gender", labour["gender"]),
          _infoRow(Icons.location_city, "District", labour["district"]),
          _infoRow(Icons.map, "Taluka", labour["taluka"]),
          _infoRow(Icons.home, "Village", labour["village"]),
          _infoRow(Icons.location_on, "Address", labour["address"]),
        ],
      ),
    );
  }

  /// Professional Details
  Widget _buildProfessionalDetails() {
    final List subs = labour["sub_category"] ?? [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.work, "Category", labour["work_category"]),
          const SizedBox(height: 10),
          const Text(
            "Sub Categories",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: subs.map((sub) => Chip(label: Text(sub))).toList(),
          )
        ],
      ),
    );
  }

  /// Info Row
  Widget _infoRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value?.toString() ?? "-"),
          )
        ],
      ),
    );
  }

  /// Phone Row (Masked Number)
  Widget _buildPhoneRow(dynamic phone) {
    final String phoneNumber = phone?.toString() ?? "-";

    String maskedNumber = phoneNumber;

    if (phoneNumber.length >= 4 && phoneNumber != "-") {
      String first = phoneNumber.substring(0, 2);
      String last = phoneNumber.substring(phoneNumber.length - 2);
      String middle = "*" * (phoneNumber.length - 4);

      maskedNumber = "$first$middle$last";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const Icon(Icons.phone, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          const Text(
            "Phone: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              maskedNumber,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}