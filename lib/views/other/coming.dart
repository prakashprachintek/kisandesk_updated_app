import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ComingSoonPage extends StatefulWidget {
  const ComingSoonPage({super.key});

  @override
  State<ComingSoonPage> createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initialiseNotifications();
  }

  Future<void> _initialiseNotifications() async {
    // /*
    // Print FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print("⭐⭐FCM Token: $token");
    // */

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showLocalNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'You clicked the button!',
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 48, 155, 73),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              
              'Coming Soon....!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 48, 155, 73),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: showLocalNotification,
                child: const Text("Send Test Notification"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
