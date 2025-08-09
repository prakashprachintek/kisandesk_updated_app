import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/api_config.dart';
import 'notification_data.dart';
import 'user_session.dart';

class NotificationPage extends StatefulWidget {
  final NotificationData notificationData;

  const NotificationPage({Key? key, required this.notificationData})
      : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? actionStatus; // "accepted" or "rejected"

  Future<void> _acceptRequest() async {
    final url = Uri.parse('${KD.api}/admin/machinery_request_action_play');
    final body = {
      "requestId": widget.notificationData.reqId,
      "acceptedBy": UserSession.userId,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          actionStatus = "accepted";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _rejectRequest() {
    setState(() {
      actionStatus = "rejected";
    });
  }

  Widget _buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🆔🆔🆔${widget.notificationData.reqId}');
    print('🔔🔔🔔⭐⭐Notification data: ${widget.notificationData.toMap()}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request for machine'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextRow('Request ID:', widget.notificationData.reqId),
                    _buildTextRow(
                        'Machinery:', widget.notificationData.machineryType),
                    _buildTextRow(
                        'Work Type:', widget.notificationData.workType),
                    _buildTextRow(
                        'Work Date:', widget.notificationData.workDate),
                    _buildTextRow(
                        'Area/Time:', widget.notificationData.workInQuantity),
                    _buildTextRow(
                        'Description:', widget.notificationData.description),
                    const SizedBox(height: 16),
                    if (actionStatus == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _acceptRequest,
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white),
                              label: const Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _rejectRequest,
                              icon:
                                  const Icon(Icons.cancel, color: Colors.white),
                              label: const Text(
                                'Reject',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          actionStatus == 'accepted'
                              ? "You've Accepted this Request"
                              : "You've Rejected this Request",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: actionStatus == 'accepted'
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}