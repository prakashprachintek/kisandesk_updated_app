import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

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
            "Orders_&_Transactions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ).tr(),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            tabs: [
              // Tab(text: "Orders", icon: Icon(Icons.list_alt)),
              // Tab(text: "Transactions", icon: Icon(Icons.account_balance_wallet)),
              Tab(text: tr("My_Orders")),
              Tab(text: tr("My_Transactions")),
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
