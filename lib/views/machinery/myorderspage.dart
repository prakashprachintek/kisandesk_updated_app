import 'package:flutter/material.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Map<String, String>> orders = [];

  @override
  void initState() {
    super.initState();
    // API call will be here later
    _loadDummyData();
  }

  void _loadDummyData() {
    orders = [
      {
        "orderId": "ORD123456",
        "owner": "Ramesh Kumar",
        "status": "Completed",
        "total": "₹4500",
        "paid": "₹4500",
        "booked": "12 July 2025",
        "completed": "15 July 2025",
      },
      {
        "orderId": "ORD123457",
        "owner": "Suresh Verma",
        "status": "Pending",
        "total": "₹6000",
        "paid": "₹2000",
        "booked": "20 July 2025",
        "completed": "--",
      },
    ];
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: ${order['orderId']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Owner: ${order['owner']}"),
                        Text("Status: ${order['status']}", style: TextStyle(color: order['status'] == "Completed" ? Colors.green : Colors.orange)),
                        const SizedBox(height: 8),
                        Text("Total Amount: ${order['total']}"),
                        Text("Paid Amount: ${order['paid']}"),
                        const SizedBox(height: 8),
                        Text("Booked On: ${order['booked']}"),
                        Text("Completed On: ${order['completed']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
