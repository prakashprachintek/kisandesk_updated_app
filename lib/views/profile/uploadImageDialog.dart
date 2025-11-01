import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api_config.dart';
import '../services/image_compression.dart';

/// ---------------------------------------------------------------
/// 1. The dialog widget
/// ---------------------------------------------------------------
Future<void> uploadImageDialog({
  required BuildContext context,
  required String userId,
}) async {
  final picker = ImagePicker();
  XFile? pickedFile;
  bool isUploading = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          // -------------------------------------------------------
          // Pick image from gallery
          // -------------------------------------------------------
          Future<void> pickImage() async {
            final XFile? file =
                await picker.pickImage(source: ImageSource.gallery);
            if (file != null) {
              setState(() => pickedFile = file);
            }
          }

          // -------------------------------------------------------
          // Convert to base64 & call API
          // -------------------------------------------------------
          Future<void> uploadImage() async {
            if (pickedFile == null) return;

            setState(() => isUploading = true);

            try {
              // 1. Read original file
              File originalFile = File(pickedFile!.path);

              // 2. COMPRESS using your existing function
              final File compressedFile = await optimizeImage(originalFile);

              // 3. Read compressed bytes
              final bytes = await compressedFile.readAsBytes();
              final base64Image = base64Encode(bytes);

              // Optional: Log size for debugging
              debugPrint(
                  'Original: ${(await originalFile.length()) / 1024} KB');
              debugPrint('Compressed: ${bytes.length / 1024} KB');
              debugPrint('Base64 size: ${base64Image.length / 1024} KB');

              // 4. Send to API
              final response = await http.post(
                Uri.parse(
                    '${KD.api}/user/update_profile_pic'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  "userId": userId,
                  "imageBase64": base64Image,
                }),
              );

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile picture updated!')),
                );
                Navigator.of(context).pop();
              } else {
                // Show server response for debugging
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Upload failed: ${response.statusCode} - ${response.body}')),
                );
              }
              print('${response.statusCode} - ${response.body}');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            } finally {
              setState(() => isUploading = false);
            }
          }

          // -------------------------------------------------------
          // UI
          // -------------------------------------------------------
          return AlertDialog(
            title: const Text('Update Profile Picture'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image preview
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: pickedFile == null
                        ? const Center(
                            child: Icon(Icons.person,
                                size: 80, color: Colors.grey))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(pickedFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick Image'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isUploading ? null : uploadImage,
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload'),
              ),
            ],
          );
        },
      );
    },
  );
}
