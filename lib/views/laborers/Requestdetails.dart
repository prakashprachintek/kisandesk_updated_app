// RequestDetailsPage.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestDetailsPage extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RequestDetailsPage({Key? key, required this.requestData}) : super(key: key);

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    // Parse the date string and format it for better readability
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime.toLocal());
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                // Display Farmer ID at the top
                _buildDetailRow(
                  icon: Icons.person_pin,
                  label: "Farmer ID",
                  value: requestData['farmer_id']?.toString() ?? 'N/A',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.work_outline,
                  label: "Work Description",
                  value: requestData['work']?.toString() ?? 'N/A',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: "Work Date",
                  value: requestData['work_date_from']?.toString() ?? 'N/A',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.info_outline,
                  label: "Status",
                  value: requestData['status']?.toString() ?? 'N/A',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: "Labour Type",
                  value: requestData['labour_type']?.toString() ?? 'N/A',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.person,
                  label: "Captain",
                  value: requestData['captain']?.toString() ?? 'N/A',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.attach_money,
                  label: "Total Payment",
                  value: 'Rs. ${requestData['total_payment']?.toString() ?? '0'}',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.credit_card,
                  label: "Payment to Captain",
                  value: 'Rs. ${requestData['payment_given_to_captain']?.toString() ?? '0'}',
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.payments,
                  label: "Payment from Farmer",
                  value: 'Rs. ${requestData['payment_recieved_by_farmer']?.toString() ?? '0'}',
                ),
                const Divider(),
                if (requestData['admin_comments'] is List && requestData['admin_comments'].isNotEmpty)
                  _buildNestedList(
                    icon: Icons.comment,
                    label: "Admin Comments",
                    list: requestData['admin_comments'],
                    itemBuilder: (item) => '• ${item['message']?.toString() ?? 'N/A'}',
                  ),
                const Divider(),
                if (requestData['activity_log'] is List && requestData['activity_log'].isNotEmpty)
                  _buildNestedList(
                    icon: Icons.history,
                    label: "Activity Log",
                    list: requestData['activity_log'],
                    itemBuilder: (item) {
                      final action = item['action']?.toString() ?? 'N/A';
                      final message = item['message']?.toString() ?? '';
                      final actionAt = _formatDate(item['action_at']?.toString());
                      return '• $action - $message\n  (${actionAt})';
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
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
        _buildDetailRow(icon: icon, label: label, value: ""), // Custom row for the list title
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