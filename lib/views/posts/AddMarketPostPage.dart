import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/api_config.dart';

class AddMarketPostPage extends StatefulWidget {
  @override
  _AddMarketPostPageState createState() => _AddMarketPostPageState();
}

class _AddMarketPostPageState extends State<AddMarketPostPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _description = "";
  String _imageUrl = "";
  // For simplicity, hardcode userId. In production, fetch the current user's ID.
  String _userId = "testUser";

  void _submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse("${KD.api}/admin/insert_market_post");

      // The data to be sent to the API
      Map<String, dynamic> postData = {
        "title": _title,
        "description": _description,
        "imageUrl": _imageUrl,
        "userId": _userId,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(postData),
        );

        if (response.statusCode == 200) {
          // Success case
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Post added successfully!")));
          Navigator.pop(context); // Go back to the previous screen
        } else {
          // Handle server-side errors
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error adding post: ${response.body}")));
        }
      } catch (error) {
        // Handle network or other errors
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Network error: $error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Market Post"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter a title."
                    : null,
                onSaved: (value) => _title = value ?? "",
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter a description."
                    : null,
                onSaved: (value) => _description = value ?? "",
                maxLines: 3,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Image URL"),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter an image URL."
                    : null,
                onSaved: (value) => _imageUrl = value ?? "",
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPost,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
