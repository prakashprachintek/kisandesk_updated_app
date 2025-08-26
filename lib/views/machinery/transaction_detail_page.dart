import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/api_config.dart';
import '../services/user_session.dart';

class TransactionDetailPage extends StatefulWidget {
  final Map<String, String> transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isCalling = false;
  bool _isLoading = false;
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    // Trigger animation when the page loads for Completed status
    if (widget.transaction['status'] == 'Completed') {
      Future.delayed(Duration.zero, () {
        setState(() {
          _animate = true;
        });
      });
    }
  }

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

  Future<void> _transactionComplete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${KD.api}/app/machinery_request_action_play'),
        body: {
          "requestId": widget.transaction['requestId'],
          "acceptedBy": UserSession.userId,
          "status": "Completed"
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request failed: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transaction Details",
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
                _buildRow("Order ID", widget.transaction['orderId'] ?? '',
                    Icons.insert_drive_file),
                _buildRow("Owner", widget.transaction['full_name'] ?? 'Unknown',
                    Icons.person),
                GestureDetector(
                  onTap: widget.transaction['phone'] != 'Not Available' &&
                          !_isCalling
                      ? () async {
                          await _makePhoneCall(widget.transaction['phone']!);
                        }
                      : null,
                  child: _buildRow(
                    "Phone",
                    _isCalling
                        ? 'Calling...'
                        : widget.transaction['phone'] ?? 'Not Available',
                    Icons.phone,
                    isTappable:
                        widget.transaction['phone'] != 'Not Available' &&
                            !_isCalling,
                  ),
                ),
                _buildRow("Booking Date", widget.transaction['booked'] ?? '',
                    Icons.calendar_today),
                _buildRow(
                    "Status", widget.transaction['status'] ?? '', Icons.info),
                const SizedBox(height: 20),
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.transaction['description'] ??
                      'No description available.',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                // Conditional rendering based on status
                Center(
                  child: widget.transaction['status'] == 'Completed'
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          transform: _animate
                              ? Matrix4.identity()
                              : Matrix4.diagonal3Values(0.8, 0.8, 1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 29, 108, 92),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Completed',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _transactionComplete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 29, 108, 92),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Mark as Completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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