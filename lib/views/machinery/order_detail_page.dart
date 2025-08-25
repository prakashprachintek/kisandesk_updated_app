import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


class OrderDetailPage extends StatefulWidget {
  final Map<String, String> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isCalling = false;

  // Phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    setState(() {
      _isCalling = true;
    });

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot make call to $phoneNumber")),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isCalling = false; // Reset state after call attempt
      });
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow("Order ID", widget.order['orderId'] ?? '',
                    Icons.insert_drive_file),
                _buildRow("Owner", widget.order['full_name'] ?? 'Unknown',
                    Icons.person),
                GestureDetector(
                  onTap: widget.order['phone'] != 'Not Available'
                      ? () async {
                          await _makePhoneCall(widget.order['phone']!);
                          if (!await canLaunchUrl(Uri(
                              scheme: 'tel', path: widget.order['phone']!))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Cannot make call to ${widget.order['phone']}")),
                            );
                          }
                        }
                      : null,
                  child: _buildRow(
                    "Phone",
                    widget.order['phone'] ?? 'Not Available',
                    Icons.phone,
                    isTappable: widget.order['phone'] != 'Not Available',
                  ),
                ),
                _buildRow("Booking Date", widget.order['booked'] ?? '',
                    Icons.calendar_today),
                _buildRow("Status", widget.order['status'] ?? '', Icons.info),
                const SizedBox(height: 20),
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.order['description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, IconData icon,
      {bool isTappable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
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
