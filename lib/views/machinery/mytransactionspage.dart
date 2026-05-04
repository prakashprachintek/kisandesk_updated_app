import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_session.dart';
import '../services/api_config.dart';
import 'transaction_detail_page.dart';

class MyTransactionsPage extends StatefulWidget {
  const MyTransactionsPage({super.key});

  @override
  State<MyTransactionsPage> createState() => _MyTransactionsPageState();
}

class _MyTransactionsPageState extends State<MyTransactionsPage> {
  List<Map<String, String>> orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrdersFromApi();
  }

  Future<void> _fetchOrdersFromApi() async {
    setState(() => _isLoading = true);

    final url = Uri.parse("${KD.api}/app/get_machinary_orders");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({"userId": UserSession.userId, "type": "orders"}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final List results = json['results'];

          orders = results
    .where((item) {
      final status = (item['status'] ?? '').toString().toLowerCase();
      return status != 'rejected' && status != 'ignored';
    })
    .map<Map<String, String>>((item) {
            final farmer = item['farmerDetails'];

            String fullName = 'Unknown';
            String phone = 'Not Available';

            if (farmer is List && farmer.isNotEmpty) {
              final data = farmer[0];

              final nameData = data['full_name'];
              final phoneData = data['phone'];

              fullName = (nameData is List && nameData.isNotEmpty)
                  ? nameData.first.toString()
                  : 'Unknown';

              phone = (phoneData is List && phoneData.isNotEmpty)
                  ? phoneData.first.toString()
                  : 'Not Available';
            }

            return {
              "requestId": item['_id'] ?? '',
              "orderId": item['order_id'] ?? '',
              "machinery": item['machinery_type'] ?? 'Unknown',
              "workDate": item['work_date'] ?? '',
              "workType": item['work_type'] ?? '',
              "quantity": item['work_in_quantity'] ?? '',
              "status": item['status'] ?? '',
              "booked": item['created_at']?.split('T')[0] ?? '',
              "description":
                  item['description'] ?? 'No Description available',
              "full_name": fullName,
              "phone": phone,
            };
          }).toList();

          setState(() => _isLoading = false);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch orders")),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch orders")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching orders: $e")),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrdersFromApi,
              color: const Color(0xFF1D6C5C),
              backgroundColor: Colors.white,
              child: orders.isEmpty
                  ? Center(
                      child: Text(
                        "noTransactionsTitle",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ).tr(),
                    )
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TransactionDetailPage(
                                        transaction: order),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color.fromARGB(215, 223, 241, 223),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order ID: ${order['orderId']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Booked: ${order['booked']}"),
                                    Text(
                                      "Status: ${order['status']}",
                                      style: const TextStyle(
                                          color: Color(0xFF1D6C5C)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text("Farmer: ${order['full_name']}"),
                                GestureDetector(
                                  onTap: order['phone'] != 'Not Available'
                                      ? () =>
                                          _makePhoneCall(order['phone']!)
                                      : null,
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone,
                                          size: 20, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${order['phone']}",
                                        style: TextStyle(
                                          color: order['phone'] !=
                                                  'Not Available'
                                              ? Colors.blue
                                              : Colors.grey,
                                          decoration: order['phone'] !=
                                                  'Not Available'
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
                        );
                      },
                    ),
            ),
    );
  }
}