// MyPostPage.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'PostDetailsPage.dart';

class MyPostPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  const MyPostPage({Key? key, required this.userData, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference postsRef = FirebaseDatabase.instance.ref("marketPosts");

    return StreamBuilder(
      stream: postsRef.onValue,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Map<dynamic, dynamic>? data = snapshot.data.snapshot.value as Map?;
        if (data == null) {
          return Center(child: Text("No posts found."));
        }
        List<Map<String, dynamic>> posts = data.values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        // Include only posts created by the current user.
        posts = posts.where((post) => post['userId'] == userData['uid']).toList();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 cards per row
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailsPage(post: post),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: post["imageUrl"] != null && post["imageUrl"].isNotEmpty
                            ? Image.network(
                          post["imageUrl"],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                            : Container(color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          post["title"] ?? "No Title",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          "₹${post["price"] ?? "0"}",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
