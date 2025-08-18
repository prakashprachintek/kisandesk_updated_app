import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
    _fetchOrdersFromApi();
  }

  Future<void> _fetchOrdersFromApi() async {
    print("Fetching orders for userId: ${UserSession.userId}");
    final url = Uri.parse("${KD.api}/app/get_machinary_orders");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "userId": UserSession.userId,
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
          orders = results.map<Map<String, String>>((item) {
            // Validate ownerDetails
            final ownerDetails = item['ownerDetails'] as List<dynamic>?;
            final hasOwnerDetails = ownerDetails != null && ownerDetails.isNotEmpty;
            return {
              "orderId": item['_id'] ?? '',
              "machinery": item['machinery_type'] ?? 'Unknown',
              "workDate": item['work_date'] ?? '',
              "workType": item['work_type'] ?? '',
              "quantity": item['work_in_quantity'] ?? '',
              "status": item['status'] ?? '',
              "booked": item['created_at']?.split('T')[0] ?? '',
              "description": item['description'] ?? 'No Description available',
              "full_name": hasOwnerDetails ? ownerDetails[0]['full_name'] ?? 'Unknown' : 'Unknown',
              "phone": hasOwnerDetails ? ownerDetails[0]['phone'] ?? 'Not Available' : 'Not Available'
            };
          }).toList();
          setState(() {});
        }
      } else {
        print("Failed to fetch orders. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  // Phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot make call to $phoneNumber")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                          Text(
                            "Order ID: ${order['orderId']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Booked: ${order['booked']}"),
                              Text(
                                "Status: ${order['status']}",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text("Owner: ${order['full_name']}"),
                          GestureDetector(
                            onTap: order['phone'] != 'Not Available'
                                ? () => _makePhoneCall(order['phone']!)
                                : null,
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 20, color: Colors.grey[600]),
                                SizedBox(width: 8),
                                Text(
                                  "${order['phone']}",
                                  style: TextStyle(
                                    color: order['phone'] != 'Not Available'
                                        ? Colors.blue
                                        : Colors.grey,
                                    decoration: order['phone'] != 'Not Available'
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
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