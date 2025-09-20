import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_page.dart';
import 'notification_data.dart';
import '../services/api_config.dart';
import '../services/user_session.dart';

class AllNotificationPage extends StatefulWidget {
  const AllNotificationPage({super.key});

  @override
  State<AllNotificationPage> createState() => _AllNotificationPageState();
}

class _AllNotificationPageState extends State<AllNotificationPage> {
  List<NotificationData> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = Uri.parse('${KD.api}/app/get_notification_data');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': UserSession.userId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          // Handle null or empty push_notifications
          final pushNotifications = jsonData['results'] != null &&
                  jsonData['results'].isNotEmpty &&
                  jsonData['results'][0]['push_notifications'] != null
              ? jsonData['results'][0]['push_notifications'] as List
              : [];
          final notifications = pushNotifications
              .map((item) => NotificationData.fromMap(item))
              .toList();
          // Sort by createdAt (newest first)
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          setState(() {
            _notifications = notifications;
          });
        } else {
          setState(() {
            _error = jsonData['message'] ?? 'Failed to fetch notifications';
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching notifications: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String reqId) async {
    try {
      final url = Uri.parse('${KD.api}/app/update_notification_data');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': UserSession.userId,
          'requestId': reqId,
          'read': true,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final notification = _notifications.firstWhere((n) => n.reqId == reqId);
          notification.read = true;
        });
      } else {
        print('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Widget _buildNotificationTile(NotificationData notification) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'From: ${notification.farmerName}\n${notification.body}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          notification.workDate,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationPage(
                notificationData: notification,
              ),
            ),
          ).then((_) {
            if (!notification.read) {
              _markAsRead(notification.reqId);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications available'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationTile(_notifications[index]);
                      },
                    ),
    );
  }
}