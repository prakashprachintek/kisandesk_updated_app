import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthOptionCard extends StatelessWidget {
  final String lottieFile;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AuthOptionCard({
    Key? key,
    required this.lottieFile,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Lottie.asset(lottieFile),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }
}
