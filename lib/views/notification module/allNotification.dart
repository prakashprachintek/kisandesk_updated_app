import 'package:flutter/material.dart';

class allNotificationPage extends StatefulWidget {
  const allNotificationPage({super.key});

  @override
  State<allNotificationPage> createState() => _allNotificationPageState();
}

class _allNotificationPageState extends State<allNotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "All Notifications",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
