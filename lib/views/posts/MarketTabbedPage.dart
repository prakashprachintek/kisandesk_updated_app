import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'PostDetailsPage.dart';
import 'MyTransactionPage.dart'; // Ensure this file exists in your project

class MarketTabbedPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String? phoneNumber; // Optional phone number

  const MarketTabbedPage({
    Key? key,
    required this.userData,
    this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Posts, My Posts, and Transactions
      child: Scaffold(
        appBar: AppBar(
          title: Text("Market"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF4CAF50),
                  Color(0xFFFFD600),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Posts"),
              Tab(text: "My Posts"),
              Tab(text: "Transactions"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PostsTab(userData: userData),
            MyPostsTab(userData: userData),
            MyTransactionPage(),
          ],
        ),
      ),
    );
  }
}

class PostsTab extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PostsTab({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference postsRef = FirebaseDatabase.instance.ref("marketPosts");

    return StreamBuilder<DatabaseEvent>(
      stream: postsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null)
          return Center(child: Text("No posts available."));
        Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> posts =
        data.values.map((e) => Map<String, dynamic>.from(e)).toList();

        // Show all posts
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // three cards per row
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
                  MaterialPageRoute(builder: (_) => PostDetailsPage(post: post)),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section using Base64
                    Expanded(
                      child: post["base64Image"] != null &&
                          post["base64Image"].toString().isNotEmpty
                          ? Image.memory(
                        base64Decode(post["base64Image"]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                          : Container(color: Colors.grey),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        post["cropName"] ?? "No Title",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "₹${post["price"]?.toString() ?? "0"}",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MyPostsTab extends StatelessWidget {
  final Map<String, dynamic> userData;
  const MyPostsTab({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference postsRef = FirebaseDatabase.instance.ref("marketPosts");

    return StreamBuilder<DatabaseEvent>(
      stream: postsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null)
          return Center(child: Text("No posts available."));
        Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> posts =
        data.values.map((e) => Map<String, dynamic>.from(e)).toList();
        // Filter posts to include only those created by the current user
        posts = posts.where((post) => post['userId'] == userData['uid']).toList();
        if (posts.isEmpty) {
          return Center(child: Text("No posts available."));
        }
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
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
                  MaterialPageRoute(builder: (_) => PostDetailsPage(post: post)),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use Base64 image
                    Expanded(
                      child: post["base64Image"] != null &&
                          post["base64Image"].toString().isNotEmpty
                          ? Image.memory(
                        base64Decode(post["base64Image"]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                          : Container(color: Colors.grey),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        post["cropName"] ?? "No Title",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "₹${post["price"]?.toString() ?? "0"}",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
