import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/laborers/Labour_orders.dart';
import 'package:mainproject1/views/laborers/Labourrequest_new.dart';
import 'package:mainproject1/views/laborers/Requestdetails.dart';
import 'package:mainproject1/views/profile/personalDetailsPage.dart';
import 'package:mainproject1/views/services/AppAssets.dart';
import 'dart:convert';
import '../services/user_session.dart';
import '../services/api_config.dart';
import 'package:easy_localization/easy_localization.dart';

class LabourBookingPage extends StatefulWidget {
  const LabourBookingPage({super.key});

  @override
  _LabourBookingPageState createState() => _LabourBookingPageState();
}

class _LabourBookingPageState extends State<LabourBookingPage> {
  final List<String> imagePaths = [
    AppAssets.paddy1,
    AppAssets.paddy2,
    AppAssets.paddy3,
    AppAssets.paddy4
  ];

  late Future<List<dynamic>> _recentOrdersFuture;

  @override
  void initState() {
    super.initState();
    _recentOrdersFuture = _fetchRecentOrders();
  }

  Future<List<dynamic>> _fetchRecentOrders() async {
    final String? farmerId = UserSession.userId;
    if (farmerId == null) {
      throw Exception("User not logged in. Cannot fetch requests.");
    }

    final Uri apiUrl = Uri.parse('${KD.api}/admin/get_labours_request');
    final Map<String, String> body = {'farmer_id': farmerId};

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success' && data['results'] != null) {
          List<dynamic> allRequests = data['results'];

          allRequests.sort((a, b) {
            final DateTime dateA = DateTime.parse(a['work_date_from']);
            final DateTime dateB = DateTime.parse(b['work_date_from']);
            return dateB.compareTo(dateA);
          });

          return allRequests.take(2).toList();
        }
        return [];
      } else {
        throw Exception("Failed to load labour requests: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching recent orders: $e");
      throw Exception("An error occurred: $e");
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _recentOrdersFuture = _fetchRecentOrders();
    });
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
            tr("Please update your information to book labour"),
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
        MaterialPageRoute(builder: (context) => LabourrequestNew()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("Labour Booking"),
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
                      onTap: _checkProfileAndNavigate, // Updated to check profile
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
                            builder: (context) => LabourRequestOrdersPage(),
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
                FutureBuilder<List<dynamic>>(
                  future: _recentOrdersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text(tr("Error: ${snapshot.error}")));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(tr("No recent orders found.")));
                    }

                    final recentOrders = snapshot.data!;
                    return ListView.builder(
                      itemCount: recentOrders.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = recentOrders[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RequestDetailsPage(requestData: item),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['order_id']?.toString() ??
                                        tr('orderId unavailable'),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month_outlined,
                                          size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                          'Date: ${item['work_date_from']?.toString() ?? 'N/A'}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                          'Gender: ${item['labour_type']?.toString() ?? 'N/A'}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                          'Status: ${item['status']?.toString() ?? 'N/A'}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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