import 'package:flutter/material.dart';

import 'myorderspage.dart';
import 'mytransactionspage.dart';

class Ordertransactiontab extends StatelessWidget {
  const Ordertransactiontab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // number of tabs
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Orders & Transactions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            tabs: [
              // Tab(text: "Orders", icon: Icon(Icons.list_alt)),
              // Tab(text: "Transactions", icon: Icon(Icons.account_balance_wallet)),
              Tab(text: "My Orders"),
              Tab(text: "My Transactions"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyOrdersPage(),
            MyTransactionsPage(),
          ],
        ),
      ),
    );
  }
}
