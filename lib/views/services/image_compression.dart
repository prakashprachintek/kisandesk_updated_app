import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<File> optimizeImage(File imageFile) async {
  // 1. Calculate size in KB
  final int sizeInBytes = await imageFile.length();
  final double sizeInKB = sizeInBytes / 1024;
  
  // Define compression quality based on initial size
  int quality = 100;

  if (sizeInKB > 500 && sizeInKB <= 1000) {
    quality = 85; // Medium compression
  } else if (sizeInKB > 1000 && sizeInKB <= 2000) {
    quality = 70; // Higher compression
  } else if (sizeInKB > 2000 && sizeInKB <= 3000) {
    quality = 50; // Significant compression
  } else if (sizeInKB > 3000) {
    quality = 40; // Heavy compression
  }

  // If quality is 100, we skip compression to save processing time
  if (quality == 100) {
    return imageFile;
  }
  
  // 2. Define the output path in the device's temporary directory
  final dir = await path_provider.getTemporaryDirectory();
  final targetPath =
      "${dir.absolute.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

  // 3. Perform compression
  final XFile? compressedFile =
      await FlutterImageCompress.compressAndGetFile(
    imageFile.absolute.path,
    targetPath,
    minWidth: 1000, // Optional: Resize to a max width (good practice for large photos)
    minHeight: 1000, // Optional: Resize to a max height
    quality: quality,
    format: CompressFormat.jpeg,
  );

  // 4. Return the compressed file (or the original if compression failed)
  return compressedFile != null ? File(compressedFile.path) : imageFile;
}