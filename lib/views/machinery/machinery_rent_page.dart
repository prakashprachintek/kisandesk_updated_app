import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../machinery/bookpage.dart';
import '../machinery/myorderspage.dart';
import '../other/user_session.dart';
import '../widgets/api_config.dart';

class MachineryRentPage extends StatefulWidget {
  const MachineryRentPage({super.key});

  @override
  _MachineryRentPageState createState() => _MachineryRentPageState();
}

class _MachineryRentPageState extends State<MachineryRentPage> {
  final List<String> imagePaths = [
    'assets/JCB.jpeg',
    'assets/harvester.jpg',
    'assets/rotavator.jpg',
    'assets/tractor.jpg',
  ];

  List<Map<String, String>> recentOrders = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentOrders();
  }

  Future<void> _fetchRecentOrders() async {
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
        if (json['status'] == 'success') {
          final List results = json['results'];

          results.sort((a, b) =>
              b['created_at'].toString().compareTo(a['created_at'].toString()));

          final recent = results.take(2).map<Map<String, String>>((item) {
            return {
              "orderId": item['_id'] ?? '',
              "workType": item['farmer_name'] ?? 'Unknown',
              "status": item['status'] ?? '',
              "date": item['created_at']?.split('T')[0] ?? '',
              "contact": item['contact_number'] ?? '--',
            };
          }).toList();

          setState(() {
            recentOrders = recent;
          });
        }
      } else {
        print("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching recent orders: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Machinery Rent",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        color: const Color(0xFFEEF3F9),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel
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

              // Grid Buttons
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2, //size of those buttons
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
                    page: const MyOrdersPage(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                "Recent Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Limited Recent Orders (2 only)
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : recentOrders.isEmpty
                        ? Center(child: Text("No recent orders found"))
                        : ListView.builder(
                            itemCount: recentOrders.length,
                            itemBuilder: (context, index) {
                              final order = recentOrders[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("🆔 Order ID: ${order['orderId']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text("🔧 Work Type: ${order['workType']}"),
                                    Text("📅 Date: ${order['date']}"),
                                    Text("📞 Contact: ${order['contact']}"),
                                    Text("📌 Status: ${order['status']}"),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
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
