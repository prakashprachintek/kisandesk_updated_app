import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ComingSoonPage extends StatefulWidget {
  const ComingSoonPage({super.key});

  @override
  State<ComingSoonPage> createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Coming Soon",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00AD83),
        iconTheme: const IconThemeData(
          color: Colors.white,
          
        ),
      ),
      body: Center(
        child: Lottie.asset(
          'assets/animations/coming_soon.json',
          width: 300,
          height: 400,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
