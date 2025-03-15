// CombinedDashboardPage.dart
import 'package:flutter/material.dart';
import '../home/DashboardTab_page.dart';
import '../posts/MyTransactionPage.dart';
import 'MyPostsPage.dart';
import 'Post_page.dart';

class CombinedDashboardPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  const CombinedDashboardPage({
    Key? key,
    required this.userData,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Labour Requests, Posts, My Posts, My Transactions
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B5E20), // Dark Green
                  Color(0xFF4CAF50), // Green
                  Color(0xFFFFD600), // Bright Yellow
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Labour Requests'),
              Tab(text: 'Posts'),
              Tab(text: 'My Posts'),
              Tab(text: 'My Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LabourRequestsTab(userData: userData),
            PostPage(userData: userData),
            MyPostPage(userData: userData, phoneNumber: phoneNumber),
            MyTransactionPage(),
          ],
        ),
      ),
    );
  }
}
