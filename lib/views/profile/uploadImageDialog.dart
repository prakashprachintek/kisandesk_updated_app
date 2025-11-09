import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api_config.dart';
import '../services/image_compression.dart';

/// ---------------------------------------------------------------
/// uploadImageDialog
/// Returns:
///   - on success:  {'success': true}
///   - on failure:  {'success': false, 'message': <error text>}
/// ---------------------------------------------------------------
Future<Map<String, dynamic>?> uploadImageDialog({
  required BuildContext context,
  required String userId,
}) async {
  final picker = ImagePicker();
  XFile? pickedFile;
  bool isUploading = false;

  return await showDialog<Map<String, dynamic>?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          // --------------------------------------------------------
          // Pick from gallery
          // --------------------------------------------------------
          Future<void> pickFromGallery() async {
            final XFile? file =
                await picker.pickImage(source: ImageSource.gallery);
            if (file != null) setState(() => pickedFile = file);
          }

          // --------------------------------------------------------
          // Take photo
          // --------------------------------------------------------
          Future<void> takePhoto() async {
            final XFile? file =
                await picker.pickImage(source: ImageSource.camera);
            if (file != null) setState(() => pickedFile = file);
          }

          // --------------------------------------------------------
          // Upload → Update
          // --------------------------------------------------------
          Future<Map<String, dynamic>> uploadImage() async {
            if (pickedFile == null) {
              return {'success': false, 'message': 'No image selected'};
            }

            setState(() => isUploading = true);

            try {
              // 1. Compress
              final File originalFile = File(pickedFile!.path);
              final File compressedFile = await optimizeImage(originalFile);
              final Uint8List bytes = await compressedFile.readAsBytes();

              // 2. Upload to /upload_document
              final uploadUri = Uri.parse('${KD.api}/upload_document');
              final request = http.MultipartRequest('POST', uploadUri)
                ..files.add(http.MultipartFile.fromBytes(
                  'file',
                  bytes,
                  filename: pickedFile!.name,
                ));

              final streamed = await request.send();
              final uploadResp =
                  await http.Response.fromStream(streamed);

              if (uploadResp.statusCode != 200) {
                return {
                  'success': false,
                  'message':
                      'Upload failed (${uploadResp.statusCode})\n${uploadResp.body}'
                };
              }

              // 3. Update profile pic
              final fileName = pickedFile!.name;
              final updateUri =
                  Uri.parse('${KD.api}/user/update_profile_pic');
              final updateResp = await http.post(
                updateUri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  "userId": userId,
                  "fileName": fileName,
                }),
              );

              if (updateResp.statusCode == 200) {
                return {'success': true};
              } else {
                return {
                  'success': false,
                  'message':
                      'Update failed (${updateResp.statusCode})\n${updateResp.body}'
                };
              }
            } catch (e, st) {
              debugPrint('Upload exception: $e\n$st');
              return {'success': false, 'message': 'Error: $e'};
            } finally {
              if (context.mounted) setState(() => isUploading = false);
            }
          }

          // --------------------------------------------------------
          // UI
          // --------------------------------------------------------
          return AlertDialog(
            title: const Text('Update Profile Picture'),
            content: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 340, minWidth: 280),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview
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

                    // Take Photo
                    Row(
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

                    // Pick Image
                    Row(
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
                onPressed: isUploading
                    ? null
                    : () async {
                        final result = await uploadImage();
                        Navigator.of(context).pop(result);
                      },
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