import 'package:flutter/material.dart';

class AddMeAsLabour extends StatelessWidget {
  const AddMeAsLabour({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add me as a labour'),
        // centerTitle: true,
      ),
      body: const SizedBox.shrink(), // blank page
    );
  }
}
