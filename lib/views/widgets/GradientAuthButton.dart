import 'package:flutter/material.dart';

class GradientAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap; // Changed to VoidCallback? for InkWell compatibility
  final TextStyle? textStyle; // Made textStyle nullable for flexibility
  final double opacity; // Added for visual feedback

  const GradientAuthButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.textStyle, // Optional textStyle
    this.opacity = 1.0, // Default opacity is 1.0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity, // Apply opacity for visual feedback
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap, // Directly use onTap to respect null (disabled) state
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1B5E20),
                Color(0xFF1B5E20),
                Color(0xFF1B5E20),
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
            style: textStyle ??
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}