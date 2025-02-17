import 'package:flutter/material.dart';

class GradientAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GradientAuthButton({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF4CAF50),
              Color(0xFFFFD600),
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
