import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/image_compression.dart'; // your existing compressor

class UploadTestPage extends StatefulWidget {
  const UploadTestPage({Key? key}) : super(key: key);

  @override
  State<UploadTestPage> createState() => _UploadTestPageState();
}

class _UploadTestPageState extends State<UploadTestPage> {
  final ImagePicker _picker = ImagePicker();
  File? image;
  bool isUploading = false;
  String serverResponse = "";
  String uploadedFileName = "";

  Future<void> pickAndUpload() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1400,
      maxHeight: 1400,
    );

    if (picked == null) return;

    try {
      setState(() {
        isUploading = true;
        serverResponse = "";
        uploadedFileName = "";
      });

      final originalFile = File(picked.path);
      final compressedFile = await optimizeImage(originalFile);

      image = compressedFile;

      final fileName = compressedFile.path.split(Platform.pathSeparator).last;

      print("══════════════════════════════════════");
      print("LOCAL FILE PATH: ${compressedFile.path}");
      print("LOCAL FILE NAME: $fileName");
      print("══════════════════════════════════════");

      final uploadUri = Uri.parse("${KD.api}/upload_document");
      final request = http.MultipartRequest('POST', uploadUri);

      request.files.add(
        await http.MultipartFile.fromPath('file', compressedFile.path),
      );

      print("→ Uploading to: $uploadUri");

      final response = await request.send();
      final body = await response.stream.bytesToString();

      print("══════════════════════════════════════");
      print("UPLOAD STATUS: ${response.statusCode}");
      print("UPLOAD RESPONSE: $body");
      print("══════════════════════════════════════");

      setState(() {
        serverResponse = body;
        uploadedFileName = fileName;
      });
    } catch (e) {
      print("UPLOAD ERROR: $e");
      setState(() {
        serverResponse = "ERROR: $e";
      });
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Test Page")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(image!, fit: BoxFit.cover),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isUploading ? null : pickAndUpload,
              child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pick → Compress → Upload"),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Uploaded File Name:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SelectableText(
              uploadedFileName.isEmpty
                  ? "No file uploaded yet"
                  : uploadedFileName,
              style: const TextStyle(color: Colors.green),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Server Response:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    serverResponse.isEmpty
                        ? "No response yet"
                        : serverResponse,
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
