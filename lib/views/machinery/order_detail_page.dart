import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, String> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Color(0xFF00AD83),
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
                _buildRow("Order ID", order['orderId'] ?? ''),
                _buildRow("Owner", order['owner'] ?? ''),
                _buildRow("Booking Date", order['booked'] ?? ''),
                _buildRow("Status", order['status'] ?? ''),
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

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
