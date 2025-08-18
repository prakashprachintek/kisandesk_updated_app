import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, String> order;

  const OrderDetailPage({super.key, required this.order});

  // Helper to launch phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Note: ScaffoldMessenger requires a BuildContext, so we'll handle this in the widget
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow("Order ID", order['orderId'] ?? '', Icons.insert_drive_file),
                _buildRow("Owner", order['full_name'] ?? 'Unknown', Icons.person),
                GestureDetector(
                  onTap: order['phone'] != 'Not Available'
                      ? () async {
                          await _makePhoneCall(order['phone']!);
                          if (!await canLaunchUrl(Uri(scheme: 'tel', path: order['phone']!))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Cannot make call to ${order['phone']}")),
                            );
                          }
                        }
                      : null,
                  child: _buildRow(
                    "Phone",
                    order['phone'] ?? 'Not Available',
                    Icons.phone,
                    isTappable: order['phone'] != 'Not Available',
                  ),
                ),
                _buildRow("Booking Date", order['booked'] ?? '', Icons.calendar_today),
                _buildRow("Status", order['status'] ?? '', Icons.info),
                const SizedBox(height: 20),
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  order['description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, IconData icon, {bool isTappable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isTappable ? Colors.blue : Colors.black87,
              decoration: isTappable ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }
}