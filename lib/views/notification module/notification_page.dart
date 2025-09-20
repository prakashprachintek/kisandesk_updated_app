import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_config.dart';
import 'notification_data.dart';
import '../services/user_session.dart';

class NotificationPage extends StatefulWidget {
  final NotificationData notificationData;

  const NotificationPage({Key? key, required this.notificationData}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? actionStatus; // Local state for UI
  String? backendStatus; // Status from get_single_order_details API
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails(); // Fetch request details on page load
    if (!widget.notificationData.read) {
      _markAsRead(); // Mark notification as read if not already
    }
  }

  // Fetch request details using the new API
  Future<void> _fetchRequestDetails() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${KD.api}/app/get_single_order_details');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': widget.notificationData.reqId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['results'].isNotEmpty) {
          setState(() {
            backendStatus = data['results'][0]['status'];
          });
        } else {
          print('Failed to fetch request details: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching request details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Mark notification as read
  Future<void> _markAsRead() async {
    try {
      final url = Uri.parse('${KD.api}/app/update_notification_data');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': UserSession.userId,
          'requestId': widget.notificationData.reqId, // Include requestId
          'read': true,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.notificationData.read = true;
        });
      } else {
        print('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Accept request
  Future<void> _acceptRequest() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('${KD.api}/app/machinery_request_action_play');
    final body = {
      'requestId': widget.notificationData.reqId,
      'acceptedBy': UserSession.userId,
      'status': 'accepted',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            actionStatus = 'accepted';
            backendStatus = 'accepted'; // Update backend status
            widget.notificationData.read = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Request accepted')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to accept request')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Reject request
  Future<void> _rejectRequest() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('${KD.api}/app/machinery_request_action_play');
    final body = {
      'requestId': widget.notificationData.reqId,
      'acceptedBy': UserSession.userId,
      'status': 'rejected',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            actionStatus = 'rejected';
            backendStatus = 'rejected'; // Update backend status
            widget.notificationData.read = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Request rejected')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to reject request')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
    print('🆔 Request ID: ${widget.notificationData.reqId}');
    print('🔔 Notification data: ${widget.notificationData.toMap()}');
    print('📊 Backend Status: $backendStatus');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request for Machine'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextRow('Request ID:', widget.notificationData.reqId),
                        _buildTextRow('Requested by:', widget.notificationData.farmerName),
                        _buildTextRow('Contact:', widget.notificationData.phone),
                        _buildTextRow('Machinery:', widget.notificationData.machineryType),
                        _buildTextRow('Work Type:', widget.notificationData.workType),
                        _buildTextRow('Work Date:', widget.notificationData.workDate),
                        _buildTextRow('Area/Time:', widget.notificationData.workInQuantity),
                        _buildTextRow('Description:', widget.notificationData.description),
                        const SizedBox(height: 16),
                        if (backendStatus == null || backendStatus == 'Pending') ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _acceptRequest,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.check_circle, color: Colors.white),
                                  label: Text(
                                    _isLoading ? 'Accepting...' : 'Accept',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _rejectRequest,
                                  icon: const Icon(Icons.cancel, color: Colors.white),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Center(
                            child: Text(
                              backendStatus == 'accepted'
                                  ? "You've Accepted this Request"
                                  : backendStatus == 'rejected'
                                      ? "You've Rejected this Request"
                                      : "Request Status: $backendStatus",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: backendStatus == 'accepted'
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}