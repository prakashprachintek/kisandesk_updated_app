import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mainproject1/views/services/AppAssets.dart';

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
        
        iconTheme: const IconThemeData(
          color: Colors.white,
          
        ),
      ),
      body: Center(
        child: Lottie.asset(
          AppAssets.animComingSoon,
          width: 300,
          height: 400,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
