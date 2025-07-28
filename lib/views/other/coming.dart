import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 48, 155, 73),
      ),
      body: Center(
        child: Text(
          'Coming Soon....!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 48, 155, 73),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
