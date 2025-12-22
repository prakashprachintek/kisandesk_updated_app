import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../services/user_session.dart';
import '../services/api_config.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isCalling = false;
  bool _isRetrying = false;

  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _canRetry = false;

  @override
  void initState() {
    super.initState();
    _setupRetryTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------- TIME LOGIC ----------------

  void _setupRetryTimer() {
    _calculateRetryState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRetryState();
    });
  }

  void _calculateRetryState() {
    final createdAtRaw = widget.order['createdAt'];

    if (createdAtRaw == null || createdAtRaw.isEmpty) {
      _canRetry = false;
      return;
    }

    final DateTime createdAtUtc =
        DateTime.parse(createdAtRaw).toUtc();

    final DateTime retryAllowedAtUtc =
        createdAtUtc.add(const Duration(hours: 3));

    final DateTime nowUtc = DateTime.now().toUtc();

    final Duration diff = retryAllowedAtUtc.difference(nowUtc);

    setState(() {
      if (diff.isNegative) {
        _canRetry = true;
        _remainingTime = Duration.zero;
      } else {
        _canRetry = false;
        _remainingTime = diff;
      }
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // ---------------- RETRY API ----------------

  Future<void> _retryBooking() async {
    if (_isRetrying || !_canRetry) return;

    final mongoId = widget.order['rawMongoId'] as String?;
    final fallbackOrderId =
        widget.order['rawOrderId'] as String? ??
            widget.order['orderId'] as String?;

    final orderIdentifier =
        mongoId?.isNotEmpty == true ? mongoId : fallbackOrderId;

    if (orderIdentifier == null || orderIdentifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing order identifier")),
      );
      return;
    }

    setState(() => _isRetrying = true);

    final url = Uri.parse("${KD.api}/app/retry_machinary_book");

    final body = {
      "orderId": orderIdentifier,
      "machineryType": widget.order['rawMachineryType'] ?? '',
      "workType": widget.order['rawWorkType'] ?? '',
      "userId": UserSession.userId,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Retry request sent successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['message'] ?? "Retry failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  // ---------------- CALL ----------------

  Future<void> _makePhoneCall(String phoneNumber) async {
    setState(() => _isCalling = true);
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    setState(() => _isCalling = false);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final orderId = widget.order['orderId'] ?? 'N/A';
    final owner = widget.order['full_name'] ?? 'Unknown';
    final phone = widget.order['phone'] ?? 'Not Available';
    final status = widget.order['status'] ?? '';
    final bookedDate = widget.order['booked'] ?? '';
    final description = widget.order['description'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row("Order ID", orderId, Icons.receipt),
                _row("Owner", owner, Icons.person),
                GestureDetector(
                  onTap: phone != 'Not Available'
                      ? () => _makePhoneCall(phone)
                      : null,
                  child: _row(
                    "Phone",
                    phone,
                    Icons.phone,
                    tappable: phone != 'Not Available',
                  ),
                ),
                _row("Booked Date", bookedDate, Icons.calendar_today),
                _row("Status", status, Icons.info),
                const SizedBox(height: 16),
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(description),
                const Spacer(),

                if (!_canRetry)
                  Text(
                    "Retry available in ${_formatDuration(_remainingTime)}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                const SizedBox(height: 10),

                Center(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_canRetry && !_isRetrying) ? _retryBooking : null,
                    icon: _isRetrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isRetrying
                          ? "Retrying..."
                          : _canRetry
                              ? "Retry Booking"
                              : "Retry Locked",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _canRetry ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
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

  Widget _row(String label, String value, IconData icon,
      {bool tappable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(
            value,
            style: TextStyle(
              color: tappable ? Colors.blue : Colors.black,
              decoration: tappable ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }
}
