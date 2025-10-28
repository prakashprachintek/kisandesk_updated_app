import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Show bottom sheet with options
  static Future<File?> showImagePickerBottomSheet(BuildContext context) async {
    File? imageFile;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  final XFile? picked =
                  await _picker.pickImage(source: ImageSource.camera);
                  if (picked != null) imageFile = File(picked.path);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  final XFile? picked =
                  await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) imageFile = File(picked.path);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    return imageFile;
  }
}
