import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 241, 238),
      body: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 4, 88, 23),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
