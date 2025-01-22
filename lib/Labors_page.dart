import 'package:flutter/material.dart';
import 'MenLaborersPage.dart';
import 'WomenLaborersPage.dart';
import 'TractorDriversPage.dart';
import 'RashiMissionLaborersPage.dart';

class LabourPage extends StatefulWidget {
  @override
  _LabourPageState createState() => _LabourPageState();
}

class _LabourPageState extends State<LabourPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 4 tabs
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Labour",
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: [
            Tab(
              child: Column(
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/men_labour.PNG'),
                    ),
                  ),
                  SizedBox(height: 4),
                  Expanded(
                    child: Text('Men', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/women_labour.PNG'),
                    ),
                  ),
                  SizedBox(height: 4),
                  Expanded(
                    child: Text('Women', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/tractor_driver.PNG'),
                    ),
                  ),
                  SizedBox(height: 4),
                  Expanded(
                    child: Text('Tractor', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/rashi_mission.jpg'),
                    ),
                  ),
                  SizedBox(height: 4),
                  Expanded(
                    child: Text('other', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // Add heart button functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // Add cart button functionality
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MenLaborersPage(),
          WomenLaborersPage(),
          TractorServicePage(),
          RashiMissionPage(),
        ],
      ),
    );
  }
}
