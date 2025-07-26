import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../machinery/bookpage.dart';
import '../machinery/myorderspage.dart';

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

  final List<Map<String, String>> recentOrders = [
    {
      'orderId': 'ORD1234',
      'workType': 'Harvesting',
      'status': 'Completed',
      'date': '20 July 2025',
      'contact': '9876543210'
    },
    {
      'orderId': 'ORD5678',
      'workType': 'Ploughing',
      'status': 'Pending',
      'date': '22 July 2025',
      'contact': '9123456780'
    },
    {
      'orderId': 'ORD9012',
      'workType': 'JCB Lifting',
      'status': 'Ongoing',
      'date': '23 July 2025',
      'contact': '9988776655'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Machinery Rent",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
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
                        color: Colors.white, // white helps shadow stand out
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 4), // shadow direction: bottom
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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => BookPage()));
                    },
                    icon: Icon(Icons.shopping_cart),
                    label: Text("Book"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyOrdersPage()));
                    },
                    icon: Icon(Icons.list_alt),
                    label: Text("My Orders"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Orders Heading
            Text(
              "Recent Orders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List of Recent Orders
            Expanded(
              child: ListView.builder(
                itemCount: recentOrders.length,
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🆔 Order ID: ${order['orderId']}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
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
    );
  }
}
