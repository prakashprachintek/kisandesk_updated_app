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
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http
          .post(
            Uri.parse('${KD.api}/app/get_notification_data'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': UserSession.userId}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final list = data['results']?[0]?['push_notifications'] ?? [];

        final notifications = (list as List)
            .map((e) => NotificationData.fromMap(e))
            .toList();

        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() => _notifications = notifications);
      } else {
        setState(() => _error = data['message'] ?? 'Error');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String reqId) async {
    try {
      await http.post(
        Uri.parse('${KD.api}/app/update_notification_data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': UserSession.userId,
          'requestId': reqId,
          'read': true,
        }),
      );

      final index = _notifications.indexWhere((n) => n.reqId == reqId);
      if (index != -1) {
        setState(() => _notifications[index].read = true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // 🔥 MODERN CARD UI
  Widget _tile(NotificationData n) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationPage(notificationData: n),
          ),
        );

        if (!n.read) _markAsRead(n.reqId);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.read ? Colors.white : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔔 ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D67).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                color: Color(0xFF2E7D67),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            /// 📄 CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    n.title,
                    style: TextStyle(
                      fontWeight:
                          n.read ? FontWeight.w500 : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// FARMER NAME
                  Text(
                    n.farmerName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// BODY
                  Text(
                    n.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// DATE + DOT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        n.workDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      if (!n.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D67),
                            shape: BoxShape.circle,
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifications")),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            onPressed: _fetchNotifications,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text("No Notifications"))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (_, i) => _tile(_notifications[i]),
            ),
    );
  }
}