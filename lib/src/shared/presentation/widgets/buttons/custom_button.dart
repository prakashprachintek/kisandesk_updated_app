import 'package:flutter/material.dart';
import 'package:mainproject1/src/core/style/colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.borderRadius = 30,
    this.horizontalPadding = 40,
    this.verticalPadding = 16,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.buttonPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: isLoading
          ? const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          color: AppColors.buttonSecondary,
          strokeWidth: 2.5,
        ),
      )
          : Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor ?? AppColors.buttonSecondary,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
