import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/notification%20module/ringtone_service.dart';
import 'dart:convert';
import '../services/api_config.dart';
import 'notification_data.dart';
import '../services/user_session.dart';

class NotificationPage extends StatefulWidget {
  final NotificationData notificationData;

  const NotificationPage({super.key, required this.notificationData});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? backendStatus;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _markRead();
  }

  @override
  void dispose() {
    RingtoneService.stop();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await http.post(
        Uri.parse('${KD.api}/app/get_single_order_details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': widget.notificationData.reqId}),
      );

      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() {
          backendStatus = data['results'][0]['status'];
        });
      }
    } catch (_) {}
  }

  Future<void> _markRead() async {
    await http.post(
      Uri.parse('${KD.api}/app/update_notification_data'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': UserSession.userId,
        'requestId': widget.notificationData.reqId,
        'read': true,
      }),
    );
  }

  Future<void> _action(String status) async {
    setState(() => loading = true);

    final res = await http.post(
      Uri.parse('${KD.api}/app/machinery_request_action_play'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestId': widget.notificationData.reqId,
        'acceptedBy': UserSession.userId,
        'status': status,
      }),
    );

    final data = jsonDecode(res.body);

    if (data['status'] == 'success') {
      RingtoneService.stop();
      setState(() => backendStatus = status);
    }

    setState(() => loading = false);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "completed":
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notificationData;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Request"),
        backgroundColor: const Color(0xFF2E7D67),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 👤 FARMER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.person, color: Color(0xFF2E7D67)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.farmerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 📄 DETAILS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row("Machine", n.machineryType),
                  _row("Work Type", n.workType),
                  _row("Date", n.workDate),
                  _row("Quantity", n.workInQuantity),
                  _row("Description", n.description),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📌 STATUS
            if (backendStatus != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _statusColor(backendStatus!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  backendStatus!,
                  style: TextStyle(
                    color: _statusColor(backendStatus!),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),

            /// 🔘 ACTION BUTTONS
            if (backendStatus == null || backendStatus == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Ignore"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D67),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _action('accepted'),
                      child: const Text("Accept"),
                    ),
                  ),
                ],
              ),

            if (loading) const Padding(
              padding: EdgeInsets.only(top: 10),
              child: CircularProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}