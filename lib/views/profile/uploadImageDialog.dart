import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api_config.dart';
import '../services/image_compression.dart';

/// ---------------------------------------------------------------
/// 1. The dialog widget – now with **Take Photo** option
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
          Future<void> pickFromGallery() async {
            final XFile? file =
                await picker.pickImage(source: ImageSource.gallery);
            if (file != null) {
              setState(() => pickedFile = file);
            }
          }

          // -------------------------------------------------------
          // Take a new photo
          // -------------------------------------------------------
          Future<void> takePhoto() async {
            final XFile? file =
                await picker.pickImage(source: ImageSource.camera);
            if (file != null) {
              setState(() => pickedFile = file);
            }
          }

          // -------------------------------------------------------
          // Convert to base64 & call API
          // -------------------------------------------------------
          /*
          Future<void> uploadImage() async {
            if (pickedFile == null) return;

            setState(() => isUploading = true);

            try {
              // 1. Original file
              final File originalFile = File(pickedFile!.path);

              // 2. COMPRESS using your existing function
              final File compressedFile = await optimizeImage(originalFile);

              // 3. Read compressed bytes → base64
              final bytes = await compressedFile.readAsBytes();
              final base64Image = base64Encode(bytes);

              // Optional size logs
              debugPrint(
                  'Original: ${(await originalFile.length()) / 1024} KB');
              debugPrint('Compressed: ${bytes.length / 1024} KB');
              debugPrint('Base64 size: ${base64Image.length / 1024} KB');

              // 4. Send to API
              final response = await http.post(
                Uri.parse('${KD.api}/user/update_profile_pic'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Upload failed: ${response.statusCode} - ${response.body}')),
                );
              }
              debugPrint('${response.statusCode} - ${response.body}');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            } finally {
              setState(() => isUploading = false);
            }
          }
          */


          // -------------------------------------------------------
          // Convert to base64 & call API
          // -------------------------------------------------------
          Future<void> uploadImage() async {
            if (pickedFile == null) return;

            setState(() => isUploading = true);

            try {
              final File originalFile = File(pickedFile!.path);
              final File compressedFile = await optimizeImage(originalFile);
              final bytes = await compressedFile.readAsBytes();
              final base64Image = base64Encode(bytes);

              // Size logs
              debugPrint(
                  'Original: ${(await originalFile.length()) / 1024} KB');
              debugPrint('Compressed: ${bytes.length / 1024} KB');
              debugPrint('Base64 size: ${base64Image.length / 1024} KB');

              // Send to API
              final response = await http.post(
                Uri.parse('${KD.api}/user/update_profile_pic'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  "userId": userId,
                  "imageBase64": base64Image,
                }),
              );

              // Always log full response
              debugPrint('=== BACKEND RESPONSE ===');
              debugPrint('Status: ${response.statusCode}');
              debugPrint('Body: ${response.body}');
              debugPrint('========================');

              // Prepare response text
              final String responseText = '''
              Status Code: ${response.statusCode}
              Headers: ${response.headers}
              Body:${response.body}'''
                  .trim();

              final bool isSuccess = response.statusCode == 200;

              // Show result in AlertDialog with selectable text
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    backgroundColor:
                        isSuccess ? Colors.green[50] : Colors.red[50],
                    title: Text(
                      isSuccess ? 'Upload Success' : 'Upload Failed',
                      style: TextStyle(
                        color: isSuccess ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: SelectableText(
                          responseText,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    ),
                    actions: [
                      if (!isSuccess)
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Retry'),
                        ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSuccess ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop(); // close result dialog
                          if (isSuccess) {
                            Navigator.of(context)
                                .pop(); // close main upload dialog
                          }
                        },
                        child: Text(isSuccess ? 'Done' : 'Close'),
                      ),
                    ],
                  ),
                );
              }
            } catch (e) {
              debugPrint('Exception: $e');

              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.orange[50],
                    title: const Text('Error',
                        style: TextStyle(color: Colors.orange)),
                    content: SelectableText('Exception: $e'),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            } finally {
              setState(() => isUploading = false);
            }
          }

          // -------------------------------------------------------
          // UI
          // -------------------------------------------------------
          return AlertDialog(
            title: const Text('Update Profile Picture'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 320, // keep dialog from growing too wide
                minWidth: 280,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ----- preview -----
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Container(
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
                    ),
                    const SizedBox(height: 20),

                    // ----- button 1 (Take Photo) -----
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isUploading ? null : takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ----- button 2 (Pick Image) -----
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isUploading ? null : pickFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Pick Image'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
