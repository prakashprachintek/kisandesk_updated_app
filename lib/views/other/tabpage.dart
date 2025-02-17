import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/posts/Post_page.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../posts/Mypost_Page.dart';
import '../transctions/Mytransaction_page.dart';
import 'add_page.dart';

class TabbedPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  TabbedPage({required this.userData,required this.phoneNumber});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Dashboard'),
          backgroundColor: Color(0xFF00AD83), // Your preferred color
          bottom: TabBar(
            indicatorColor: Colors.white, // Tab indicator color
            tabs: [
              Tab( text: 'post'),
              Tab( text: 'My Posts'),
              Tab( text: 'My Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            postPage(),
            MyPostPage(userData: userData,phoneNumber:phoneNumber,),
            MyTransactionPage(),

          ],
        ),
      ),
    );
  }
}

