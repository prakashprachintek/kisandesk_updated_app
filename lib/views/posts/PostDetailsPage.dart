import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class PostDetailsPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mapping of category to field labels.
    final Map<String, Map<String, String>> fieldLabelsByCategory = {
      'cattle': {
        'cropName': 'Cattle Name',
        'description': 'Cattle Description',
        'price': 'Price',
        'quantity': 'Number of Cattle',
      },
      'crop': {
        'cropName': 'Crop Name',
        'description': 'Crop Description',
        'price': 'Price',
        'quantity': 'Quantity (kg)',
      },
      'land': {
        'cropName': 'Land Name',
        'description': 'Land Description',
        'price': 'Price per Acre',
        'quantity': 'Total Area (Acres)',
      },
      'labour': {
        'cropName': 'Job Role',
        'description': 'Job Description',
        'price': 'Wages per Day',
        'quantity': 'Workers Needed',
      },
      'machinery': {
        'cropName': 'Machine Name',
        'description': 'Machine Description',
        'price': 'Price',
        'quantity': 'Quantity Available',
      },
    };

    // Determine category (use lowercase for consistency)
    String category = post["category"]?.toString().toLowerCase() ?? "default";
    Map<String, String> labels = fieldLabelsByCategory[category] ??
        {
          'cropName': 'Title',
          'description': 'Description',
          'price': 'Price',
          'quantity': 'Quantity',
        };

    // Decode the Base64 image using the correct key "base64Image"
    Widget imageWidget;
    if (post["base64Image"] != null && post["base64Image"].toString().isNotEmpty) {
      try {
        imageWidget = Image.memory(
          base64Decode(post["base64Image"]),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
        );
      } catch (e) {
        imageWidget = Container(
          height: 250,
          color: Colors.grey[300],
          child: Center(child: Text("Image Error")),
        );
      }
    } else {
      imageWidget = Container(
        height: 250,
        color: Colors.grey[300],
        child: Center(child: Text("No Image")),
      );
    }

    // Parse and format timestamp
    String formattedTime = "N/A";
    if (post["timestamp"] != null && post["timestamp"].toString().isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(post["timestamp"]);
        formattedTime = DateFormat('yyyy-MM-dd – kk:mm').format(dt);
      } catch (e) {
        formattedTime = post["timestamp"].toString();
      }
    }

    // Build product details dynamically using the mapping
    List<Widget> productDetailsWidgets = [];
    labels.forEach((key, label) {
      if (post.containsKey(key) && post[key].toString().isNotEmpty) {
        String value;
        if (key == 'price') {
          value = "₹${post[key].toString()}";
        } else {
          value = post[key].toString();
        }
        productDetailsWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$label: ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(value, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      }
    });

    // Location details (common for all categories)
    Widget locationSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location Details:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("State: ${post["state"] ?? "N/A"}", style: TextStyle(fontSize: 16)),
        Text("District: ${post["district"] ?? "N/A"}", style: TextStyle(fontSize: 16)),
        Text("Taluka: ${post["taluka"] ?? "N/A"}", style: TextStyle(fontSize: 16)),
        Text("Village: ${post["village"] ?? "N/A"}", style: TextStyle(fontSize: 16)),
        Text("Pincode: ${post["pincode"] ?? "N/A"}", style: TextStyle(fontSize: 16)),
      ],
    );

    // Contact section
    Widget contactSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Contact Information:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Phone: ${post["phoneNumber"] ?? "N/A"}", style: TextStyle(fontSize: 16)),
      ],
    );

    // Inquire button
    Widget inquireButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00AD83),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          // TODO: Implement inquiry functionality (e.g., open a contact form)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Inquiry feature coming soon.")),
          );
        },
        child: Text(
          "Inquire",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );

    // Combine all sections in a Card for a neat layout
    Widget detailsCard = Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...productDetailsWidgets,
            Divider(height: 24, thickness: 1),
            locationSection,
            Divider(height: 24, thickness: 1),
            contactSection,
            Divider(height: 24, thickness: 1),
            Text("Posted on: $formattedTime",
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(post["cropName"] ?? "Post Details"),
        backgroundColor: Color(0xFF00AD83),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            imageWidget,
            detailsCard,
            inquireButton,
          ],
        ),
      ),
    );
  }
}
