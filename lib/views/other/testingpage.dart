import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Images'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Test Images:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Image.asset('assets/machinery/tractor.jpg'),
            Image.asset('assets/machinery/JCB.jpeg'),
            Image.asset('assets/machinery/harvester.jpg'),
            Image.asset('assets/machinery/rotavator.jpg'),
            // Add more images here
          ],
        ),
      ),
    );
  }
}
