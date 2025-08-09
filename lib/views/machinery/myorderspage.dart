import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/user_session.dart';
import '../widgets/api_config.dart';
import 'order_detail_page.dart';

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
    // _loadDummyData();
    _fetchOrdersFromApi();
  }

  Future<void> _fetchOrdersFromApi() async {
    print("Fetching orders for userId: ${UserSession.userId}");
    final url = Uri.parse("${KD.api}/app/get_machinary_orders");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "userId": UserSession.userId, // ✅ Corrected here
        }),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("Orders response: ${response.body}");

        if (json['status'] == 'success') {
          final List results = json['results'];
          orders = results.map<Map<String, String>>(
            (item) {
              return {
                "orderId": item['_id'] ?? '',
                "machinery": item['contact_number'] ??
                    'Unknown', // or actual machinery name if available
                "workDate": item['post_name'] ?? '',
                "workType": item['farmer_name'] ?? '',
                "quantity": item['price'] ?? '',
                "total": item['price'] ?? 'N/A',
                "status": item['status'] ?? '',
                "paid": item['admin_comments'] != null &&
                        item['admin_comments'].isNotEmpty
                    ? item['admin_comments'][0]['message'] ?? 'Not available'
                    : 'Not available',
                "booked": item['created_at']?.split('T')[0] ?? '',
                "completed": item['status'] == "Completed"
                    ? (item['updated_at']?.split('T')[0] ?? '')
                    : "--",
                "description": item['description'] ?? 'No Description available',
              };
            },
          ).toList();
          setState(() {});
        }
      } else {
        print("Failed to fetch orders. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: order),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Order ID: ${order['orderId']}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Booked: ${order['booked']}"),
                              Text("Status: ${order['status']}",
                                  style: TextStyle(color: Colors.blue)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text("Machinery: ${order['machinery']}"),
                          Text("Work Type: ${order['workType']}"),
                          Text("Work Date: ${order['workDate']}"),
                          Text("Quantity: ${order['quantity']}"),
                          Text("Description: ${order['description']}"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
