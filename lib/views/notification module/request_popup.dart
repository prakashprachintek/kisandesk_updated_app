import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_config.dart';
import '../services/user_session.dart';
import 'notification_data.dart';
import 'ringtone_service.dart';

class RequestPopup extends StatefulWidget {
  final NotificationData notificationData;

  const RequestPopup({super.key, required this.notificationData});

  @override
  State<RequestPopup> createState() => _RequestPopupState();
}

class _RequestPopupState extends State<RequestPopup> {
  bool loading = false;

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

      Navigator.pop(context); // close popup

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notificationData;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// TITLE
            const Text(
              "New Request",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            /// FARMER
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, color: Color(0xFF2E7D67)),
              ),
              title: Text(n.farmerName),
              subtitle: Text(n.body),
            ),

            const Divider(),

            /// DETAILS
            _row("Machine", n.machineryType),
            _row("Work", n.workType),
            _row("Date", n.workDate),
            _row("Qty", n.workInQuantity),

            const SizedBox(height: 16),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      RingtoneService.stop();
                      Navigator.pop(context);
                    },
                    child: const Text("Ignore"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D67),
                    ),
                    onPressed: () => _action("accepted"),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),

            if (loading)
              const Padding(
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}