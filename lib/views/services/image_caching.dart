import 'package:flutter/material.dart';
import "package:cached_network_image/cached_network_image.dart";

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 100,
    this.height = 120,
    this.fit = BoxFit.fill,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      //fit: fit,
      // --- Custom Builders for better User Experience ---

      // 1. Placeholder while the image is loading (e.g., a simple loading indicator)
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[300], // Background color while loading
        child: const Center(
          //child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),

      // 2. Error Widget if the image fails to load
      errorWidget: (context, url, error) => Image.asset(
        'assets/land1.jpg',
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        ),
    );
  }
}