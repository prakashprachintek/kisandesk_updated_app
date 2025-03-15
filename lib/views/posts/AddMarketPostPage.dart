import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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

  final DatabaseReference postsRef = FirebaseDatabase.instance.ref("marketPosts");

  void _submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Create a new post map
      Map<String, dynamic> post = {
        "title": _title,
        "description": _description,
        "imageUrl": _imageUrl,
        "userId": _userId,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };

      try {
        await postsRef.push().set(post);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Post added successfully!")));
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error adding post: $error")));
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
                validator: (value) =>
                value == null || value.isEmpty ? "Enter title" : null,
                onSaved: (value) => _title = value ?? "",
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter description" : null,
                onSaved: (value) => _description = value ?? "",
                maxLines: 3,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Image URL"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter image URL" : null,
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
