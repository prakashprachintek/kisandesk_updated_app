import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class PostDetailsPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse timestamp if available
    DateTime? postTime;
    try {
      if (post["timestamp"] != null && post["timestamp"].toString().isNotEmpty) {
        postTime = DateTime.parse(post["timestamp"]);
      }
    } catch (e) {
      // Ignore parsing errors
      postTime = null;
    }
    String formattedTime = postTime != null
        ? DateFormat('yyyy-MM-dd – kk:mm').format(postTime)
        : "N/A";

    return Scaffold(
      appBar: AppBar(
        title: Text(post["cropName"] ?? "Post Details"),
        backgroundColor: Color(0xFF00AD83),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display image from Base64 data
            post["base64Image"] != null && post["base64Image"].toString().isNotEmpty
                ? Image.memory(
              base64Decode(post["base64Image"]),
              fit: BoxFit.cover,
              height: 250,
            )
                : Container(
              height: 250,
              color: Colors.grey,
              child: Center(child: Text("No Image")),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post["cropName"] ?? "No Crop Name",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Price: ₹${post["price"]?.toString() ?? "0"}",
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Quantity: ${post["quantity"]?.toString() ?? "0"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Category: ${post["category"] ?? "N/A"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Description:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    post["description"] ?? "No description available.",
                    style: TextStyle(fontSize: 16),
                  ),
                  Divider(height: 24, thickness: 1),
                  Text(
                    "Location Details:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "District: ${post["district"] ?? "N/A"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Taluka: ${post["taluka"] ?? "N/A"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Village: ${post["village"] ?? "N/A"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "State: ${post["state"] ?? "N/A"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Pincode: ${post["pincode"] ?? "N/A"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Divider(height: 24, thickness: 1),
                  Text(
                    "Contact Information:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Phone: ${post["phoneNumber"] ?? "N/A"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Posted on: $formattedTime",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
