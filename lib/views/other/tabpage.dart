import 'package:flutter/material.dart';
import '../posts/AllPostsPage.dart';
import '../posts/MyTransactionPage.dart';
import '../posts/Mypost_Page.dart';
import '../posts/post_page.dart';

// If you have a "userData" map that identifies the current user, pass it in here.

class TabbedPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  const TabbedPage({
    Key? key,
    required this.userData,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // posts, my posts, transactions
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Dashboard'),
          backgroundColor: Color(0xFF00AD83),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Post'),
              Tab(text: 'My Posts'),
              Tab(text: 'My Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1) Show all posts
            AllPostsPage(),

            // 2) Show only the current user's posts
            MyPostPage(userData: userData, phoneNumber: phoneNumber),
            // 3) Some placeholder for transactions
            MyTransactionPage(),
          ],
        ),
      ),
    );
  }
}
