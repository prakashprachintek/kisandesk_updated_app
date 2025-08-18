import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mainproject1/views/machinery/order_detail_page.dart';
import '../machinery/myorderspage.dart';
import '../services/user_session.dart';
import '../widgets/api_config.dart';
import 'bookpage.dart';

class MachineryRentPage extends StatefulWidget {
  const MachineryRentPage({super.key});

  @override
  _MachineryRentPageState createState() => _MachineryRentPageState();
}

class _MachineryRentPageState extends State<MachineryRentPage> {
  // List of machinery images for carousel
  final List<String> imagePaths = [
    'assets/machinery/machine_type/JCB.jpeg',
    'assets/machinery/machine_type/harvester.jpg',
    'assets/machinery/machine_type/rotavator.jpg',
    'assets/machinery/machine_type/tractor.jpg',
  ];

  // Stores recent orders fetched from backend
  List<Map<String, String>> recentOrders = [];

  // Loading state for recent orders
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentOrders(); // Fetch orders when page loads
  }

  // Fetches recent machinery orders from API
  Future<void> _fetchRecentOrders() async {
    final url = Uri.parse("${KD.api}/app/get_machinary_orders");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "userId": UserSession.userId, // Send current user's ID
        }),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final List results = json['results'];

          // Sort by creation date (latest first)
          results.sort((a, b) =>
              b['created_at'].toString().compareTo(a['created_at'].toString()));

          // Take only the 2 most recent orders
          final recent = results.take(2).map<Map<String, String>>((item) {
            return {
              "orderId": item['_id'] ?? '',
              "machine":item['machinery_type'],
              "workType": item['work_type'] ?? 'Unknown',
              "status": item['status'] ?? '',
              "date": item['created_at']?.split('T')[0] ?? '',
              "name": item['ownerDetails']?[0]['full_name'] ?? '',
              "phone": item['ownerDetails']?[0]['phone'] ?? ''
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
        isLoading = false; // Stop loader in all cases
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
      ),
      body: Container(
        color: const Color(0xFFEEF3F9),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Machinery image carousel
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

              // Two main buttons: Book & My Orders
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
                    page: const MyOrdersPage(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Section heading
              Text(
                "Recent Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Display 2 recent orders
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : recentOrders.isEmpty
                        ? Center(child: Text("No recent orders found"))
                        : ListView.builder(
                            itemCount: recentOrders.length,
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
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Machine Booked: ${order['machine']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text(
                                          "🔧 Work Type: ${order['workType']}"),
                                      Text("📅 Date: ${order['date']}"),
                                      Text("⚒️ Machine Owner: ${order['name']}"),
                                      Text("📞 Contact: ${order['phone']}"),
                                      Text("📌 Status: ${order['status']}"),
                                    ],
                                  ),
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

  // Creates a tappable tile with icon & label that navigates to a page
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
