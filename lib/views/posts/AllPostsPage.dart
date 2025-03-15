import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'PostCard.dart';
import 'PostDetailsPage.dart';

class AllPostsPage extends StatelessWidget {
  final DatabaseReference postsRef = FirebaseDatabase.instance.ref("marketPosts");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Market Posts"),
      ),
      body: StreamBuilder(
        stream: postsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          // Get data from snapshot
          Map<dynamic, dynamic>? data = snapshot.data!.snapshot.value as Map?;
          if (data == null) {
            return Center(child: Text("No posts found."));
          }
          // Convert data into a list of posts
          List<Map<String, dynamic>> posts = data.values
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> post = posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsPage(post: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/addPost");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
