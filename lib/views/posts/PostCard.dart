import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;

  const PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String title = post["title"] ?? "No Title";
    String description = post["description"] ?? "";
    String imageUrl = post["imageUrl"] ?? "";

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
            : Container(width: 50, height: 50, color: Colors.grey),
        title: Text(title),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}
