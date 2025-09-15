import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mainproject1/views/machinery/order_detail_page.dart';
import '../machinery/myorderspage.dart';
import '../services/user_session.dart';
import '../services/api_config.dart';
import 'bookpage.dart';
import 'orderTransactionTab.dart';

class MachineryRentPage extends StatefulWidget {
  const MachineryRentPage({super.key});

  @override
  _MachineryRentPageState createState() => _MachineryRentPageState();
}

class _MachineryRentPageState extends State<MachineryRentPage> {
  final List<String> imagePaths = [
    'assets/machinery/machine_type/JCB.jpeg',
    'assets/machinery/machine_type/harvester.jpg',
    'assets/machinery/machine_type/rotavator.jpg',
    'assets/machinery/machine_type/tractor.jpg',
  ];

  List<Map<String, String>> recentOrders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecentOrders();
  }

  Future<void> _fetchRecentOrders() async {
    if (UserSession.userId == null) {
      setState(() {
        isLoading = false;
        errorMessage = "User not logged in";
      });
      print("Error: UserSession.userId is null");
      return;
    }

    final url = Uri.parse("${KD.api}/app/get_machinary_orders");

    try {
      print("Fetching orders for userId: ${UserSession.userId}");
      final response = await http.post(
        url,
        body: jsonEncode({"userId": UserSession.userId, "type": "transactions"}),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("Parsed JSON: $json");

        if (json['status'] == 'success') {
          final List results = json['results'] ?? [];
          print("Results count: ${results.length}");

          results.sort((a, b) =>
              b['created_at'].toString().compareTo(a['created_at'].toString()));

          final recent = results.take(2).map<Map<String, String>>((item) {
            return {
              "orderId": item['order_id']?.toString() ?? '',
              "machine": item['machinery_type']?.toString() ?? 'Unknown',
              "workType": item['work_type']?.toString() ?? 'Unknown',
              "status": item['status']?.toString() ?? '',
              "date": item['created_at']?.toString().split('T')[0] ?? '',
              "name": item['ownerDetails']?.isNotEmpty == true
                  ? item['ownerDetails'][0]['full_name']?.toString() ?? ''
                  : 'N/A',
              "phone": item['ownerDetails']?.isNotEmpty == true
                  ? item['ownerDetails'][0]['phone']?.toString() ?? ''
                  : 'N/A',
            };
          }).toList();

          setState(() {
            recentOrders = recent;
            isLoading = false;
            errorMessage = recent.isEmpty ? "No recent orders found" : null;
          });
          print("Recent Orders: $recentOrders");
        } else {
          setState(() {
            isLoading = false;
            errorMessage = json['message'] ?? "Failed to fetch orders";
          });
          print("API status not success: ${json['message']}");
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Server error: ${response.statusCode}";
        });
        print("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error fetching orders: $e";
      });
      print("Error fetching recent orders: $e");
    }
  }

  // Function to handle pull-to-refresh
  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      recentOrders = [];
    });
    await _fetchRecentOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Machinery Rent",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFEEF3F9), // Set Scaffold background color
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 150.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: imagePaths.map((path) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    _buildTile(
                      context,
                      icon: Icons.shopping_cart,
                      label: "Book",
                      color: Colors.green,
                      page: const BookPage(),
                    ),
                    _buildTile(
                      context,
                      icon: Icons.list_alt,
                      label: "My Orders",
                      color: Colors.orange,
                      page: const Ordertransactiontab(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Recent Orders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(child: Text(errorMessage!))
                        : recentOrders.isEmpty
                            ? const Center(
                                child: Text("No recent orders found"))
                            : ListView.builder(
                                itemCount: recentOrders.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final order = recentOrders[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderDetailPage(order: order),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${order['orderId']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                              "🔧 Machine Booked: ${order['machine']}"),
                                          Text("📅 Date: ${order['date']}"),
                                          Text(
                                              "⚒️ Machine Owner: ${order['name']}"),
                                          Text("📞 Contact: ${order['phone']}"),
                                          Text("📌 Status: ${order['status']}"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required Widget page}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
