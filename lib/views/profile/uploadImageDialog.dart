import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api_config.dart';
import '../services/image_compression.dart';

/// ---------------------------------------------------------------
/// 1. The dialog widget – Take Photo + Pick Image + Upload
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
          // Pick from gallery
          // -------------------------------------------------------
          Future<void> pickFromGallery() async {
            final XFile? file =
                await picker.pickImage(source: ImageSource.gallery);
            if (file != null) setState(() => pickedFile = file);
          }

          // -------------------------------------------------------
          // Take a new photo
          // -------------------------------------------------------
          Future<void> takePhoto() async {
            final XFile? file =
                await picker.pickImage(source: ImageSource.camera);
            if (file != null) setState(() => pickedFile = file);
          }

          // -------------------------------------------------------
          // Helper – unified result dialog
          // -------------------------------------------------------
          void _showResultDialog({
            required BuildContext context,
            required bool success,
            required String title,
            required String body,
            VoidCallback? onDone,
          }) {
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: success ? Colors.green[50] : Colors.red[50],
                title: Text(
                  title,
                  style: TextStyle(
                    color: success ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      body,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (!success)
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Retry'),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onDone?.call();
                    },
                    child: Text(success ? 'Done' : 'Close'),
                  ),
                ],
              ),
            );
          }

          // -------------------------------------------------------
          // 1. Upload → 2. Update profile pic
          // -------------------------------------------------------
          Future<void> uploadImage() async {
            if (pickedFile == null) return;

            setState(() => isUploading = true);

            try {
              // ---------- 1. COMPRESS ----------
              final File originalFile = File(pickedFile!.path);
              final File compressedFile = await optimizeImage(originalFile);
              final Uint8List bytes = await compressedFile.readAsBytes();

              debugPrint(
                  'Original: ${(await originalFile.length()) / 1024} KB');
              debugPrint('Compressed: ${bytes.length / 1024} KB');

              // ---------- 2. POST to /upload_document ----------
              final uploadUri = Uri.parse('${KD.api}/upload_document');
              final request = http.MultipartRequest('POST', uploadUri)
                ..files.add(http.MultipartFile.fromBytes(
                  'file',
                  bytes,
                  filename: pickedFile!.name, // ← EXACT SAME NAME
                ));

              final streamedResponse = await request.send();
              final uploadResponse =
                  await http.Response.fromStream(streamedResponse);

              debugPrint(
                  '=== /upload_document RESPONSE ===\n'
                  'Status: ${uploadResponse.statusCode}\n'
                  'Body: ${uploadResponse.body}\n'
                  '==================================');

              if (uploadResponse.statusCode != 200) {
                _showResultDialog(
                  context: context,
                  success: false,
                  title: 'Upload Failed',
                  body:
                      'Status: ${uploadResponse.statusCode}\n${uploadResponse.body}',
                );
                return;
              }

              // ---------- 3. Use SAME filename in update API ----------
              final String fileName = pickedFile!.name; // ← NO CHANGE

              debugPrint('Using filename for update: $fileName');

              final updateUri =
                  Uri.parse('${KD.api}/user/update_profile_pic');
              final updateResponse = await http.post(
                updateUri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  "userId": userId,
                  "fileName": fileName, // ← SAME AS UPLOADED
                }),
              );

              debugPrint(
                  '=== /update_profile_pic RESPONSE ===\n'
                  'Status: ${updateResponse.statusCode}\n'
                  'Body: ${updateResponse.body}\n'
                  '=====================================');

              final bool success = updateResponse.statusCode == 200;
              _showResultDialog(
                context: context,
                success: success,
                title: success ? 'Success' : 'Update Failed',
                body:
                    'Status: ${updateResponse.statusCode}\n${updateResponse.body}',
                onDone: success
                    ? () {
                        Navigator.of(context).pop(); // close main dialog
                      }
                    : null,
              );
            } catch (e, st) {
              debugPrint('Exception: $e\n$st');
              _showResultDialog(
                context: context,
                success: false,
                title: 'Error',
                body: 'Exception: $e',
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
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340, minWidth: 280),
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

                    // ----- Take Photo -----
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

                    // ----- Pick Image -----
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