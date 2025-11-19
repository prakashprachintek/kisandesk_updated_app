import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mainproject1/views/machinery/order_detail_page.dart';
import 'package:mainproject1/views/machinery/myorderspage.dart';
import 'package:mainproject1/views/services/AppAssets.dart';
import '../services/user_session.dart';
import '../services/api_config.dart';
import 'bookpage.dart';
import 'orderTransactionTab.dart';
import 'package:mainproject1/views/profile/personalDetailsPage.dart';
import 'package:easy_localization/easy_localization.dart';

class MachineryRentPage extends StatefulWidget {
  const MachineryRentPage({super.key});

  @override
  _MachineryRentPageState createState() => _MachineryRentPageState();
}

class _MachineryRentPageState extends State<MachineryRentPage> {
  final List<String> imagePaths = [
    AppAssets.machineJCB,
    AppAssets.machineHarvester,
    AppAssets.machineRotavator,
    AppAssets.machineTractor
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
        errorMessage = tr("User not logged in");
      });
      return;
    }

    final url = Uri.parse("${KD.api}/app/get_machinary_orders");

    try {
      final response = await http.post(
        url,
        body:
            jsonEncode({"userId": UserSession.userId, "type": "transactions"}),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final List results = json['results'] ?? [];
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
            errorMessage = recent.isEmpty ? tr("No recent orders found") : null;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = json['message'] ?? tr("Failed to fetch orders");
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = tr("Server error: ${response.statusCode}");
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = tr("Error fetching orders: $e");
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      recentOrders = [];
    });
    await _fetchRecentOrders();
  }

  void _checkProfileAndNavigate() {
    final user = UserSession.user ?? {};
    final requiredFields = {
      'phone': (user['phone'] ?? '').length == 10 ? user['phone'] : null,
      'state': user['state'],
      'district': user['district'],
      'taluka': user['taluka'],
      'village': user['village'],
      'pincode': user['pincode'],
      'address': user['address'],
    };

    final missingFields = requiredFields.entries
        .where((entry) => entry.value == null || entry.value.toString().isEmpty)
        .map((entry) => entry.key)
        .toList();

    if (missingFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            tr("Incomplete Profile"),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          content: Text(
            tr("Please update your information to book machinery"),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                tr("Cancel"),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PersonalDetailsScreen()),
                );
              },
              child: Text(
                tr("Update Profile"),
                style: TextStyle(
                  color: Color.fromARGB(255, 29, 108, 92),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("Machinery Rent"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFEEF3F9),
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
                      label: tr("Book"),
                      color: Colors.green,
                      onTap:
                          _checkProfileAndNavigate, // Updated to check profile
                    ),
                    _buildTile(
                      context,
                      icon: Icons.list_alt,
                      label: tr("My Orders"),
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Ordertransactiontab(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  tr("Recent Orders"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(child: Text(tr(errorMessage!)))
                        : recentOrders.isEmpty
                            ? Center(child: Text(tr("No recent orders found")))
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
                                              "${tr('Machine Booked')}: ${order['machine']}"),
                                          Text(
                                              "${tr('Date')}: ${order['date']}"),
                                          Text(
                                              "${tr('Machine Owner')}: ${order['name']}"),
                                          Text(
                                              "${tr('Contact')}: ${order['phone']}"),
                                          Text(
                                              "${tr('Status')}: ${order['status']}"),
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

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
