// RequestDetailsPage.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestDetailsPage extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RequestDetailsPage({Key? key, required this.requestData})
      : super(key: key);

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    // Parse the date string and format it for better readability
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('yyy-MM-dd – kk:mm').format(dateTime.toLocal());
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (_, __) =>
                  const Divider(thickness: 0.8, height: 24),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildDetailRow(
                      icon: Icons.person_pin,
                      label: "Farmer ID",
                      value: requestData['farmer_id']?.toString() ?? 'N/A',
                    );
                  case 1:
                    return _buildDetailRow(
                      icon: Icons.work_outline,
                      label: "Work Description",
                      value: requestData['work']?.toString() ?? 'N/A',
                    );
                  case 2:
                    return _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: "Work Date",
                      value: _formatDate(
                          requestData['work_date_from']?.toString()),
                    );
                  case 3:
                    return _buildDetailRow(
                      icon: Icons.info_outline,
                      label: "Status",
                      value: requestData['status']?.toString() ?? 'N/A',
                    );
                  case 4:
                    return _buildDetailRow(
                      icon: Icons.people_alt,
                      label: "Labour Type",
                      value: requestData['labour_type']?.toString() ?? 'N/A',
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNestedList({
    required IconData icon,
    required String label,
    required List<dynamic> list,
    required String Function(Map<String, dynamic>) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          icon: Icons.calendar_today,
          label: "Work Date",
          value: _formatDate(requestData['work_date_from']?.toString()),
        ), // Custom row for the list title
        Padding(
          padding: const EdgeInsets.only(left: 40.0, top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.map((item) {
              if (item is Map<String, dynamic>) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    itemBuilder(item),
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        ),
      ],
    );
  }
}
