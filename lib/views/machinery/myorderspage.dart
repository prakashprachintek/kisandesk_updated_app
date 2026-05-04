import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_session.dart';
import '../services/api_config.dart';
import 'order_detail_page.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool _isLoading = true; // Track initial loading state

  Map<String, String> machineImages = {};
  bool isMachineLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrdersFromApi();
    fetchMachineImages();
  }

  Future<void> fetchMachineImages() async {
    try {
      final res = await http.post(
        Uri.parse("${KD.api}/app/get_master_data"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"type": "machine"}),
      );

      final data = jsonDecode(res.body);

      if (data["status"] == "success") {
        final list = List<Map<String, dynamic>>.from(
          data["results"][0]["machinery_type"],
        );

        Map<String, String> temp = {};

        for (var m in list) {
          final name = (m["name_in_english"] ?? m["name"] ?? "").toString();
          final image = (m["image"] ?? "").toString();

          if (name.isNotEmpty) {
            temp[name.toLowerCase()] = image;
          }
        }

        setState(() {
          machineImages = temp;
          isMachineLoading = false;
        });
      } else {
        setState(() {
          isMachineLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isMachineLoading = false;
      });

      debugPrint("Error fetching machine images: $e");
    }
  }

  Future<void> _fetchOrdersFromApi() async {
    setState(() {
      _isLoading = true;
    });

    print("Fetching orders for userId: ${UserSession.userId}");
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
        print("Orders response: ${response.body}");

        if (json['status'] == 'success') {
          final List results = json['results'];

          orders = results
    .where((item) {
      final status = (item['status'] ?? '').toString().toLowerCase();
      return status != 'rejected' && status != 'ignored';
    })
    .map<Map<String, dynamic>>((item) {
            // Safely extract owner details
            String fullName = 'Unknown';
            String phone = 'Not Available';

            final ownerDetailsRaw = item['ownerDetails'];
            if (ownerDetailsRaw is List && ownerDetailsRaw.isNotEmpty) {
              final firstOwner = ownerDetailsRaw.first;
              if (firstOwner is Map<String, dynamic>) {
                //fullName = firstOwner['full_name'] ?? 'Unknown';
                //phone = firstOwner['phone'] ?? 'Not Available';
                final nameData = firstOwner['full_name'];
                final phoneData = firstOwner['phone'];

                fullName = (nameData is List && nameData.isNotEmpty)
                    ? nameData.first.toString()
                    : 'Unknown';

                phone = (phoneData is List && phoneData.isNotEmpty)
                    ? phoneData.first.toString()
                    : 'Not Available';
              }
            }
            // If ownerDetails is null, missing, or empty → defaults stay 'Unknown'/'Not Available'

            return {
              "orderId": item['order_id'] ?? '',
              "machinery": item['machinery_type'] ?? 'Unknown',
              "workDate": item['work_date'] ?? '',
              "workType": item['work_type'] ?? '',
              "quantity": item['work_in_quantity'] ?? '',
              "status": item['status'] ?? '',
              "booked": item['created_at']?.split('T')[0] ?? '',
              "description": item['description'] ?? 'No Description available',
              "full_name": fullName,
              "phone": phone,
              // Raw fields for retry functionality
              "rawOrderId": item['order_id'] ?? '',
              "rawMachineryType": item['machinery_type'] ?? '',
              "rawWorkType": item['work_type'] ?? '',
              "createdAt": item['created_at'] ??
                  '', // fallback to empty string if missing
              "rawMongoId": item['_id'] ?? '',
            };
          }).toList();

          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch orders")),
          );
        }
      } else {
        print("Failed to fetch orders. Status code: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch orders")),
        );
      }
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching orders: $e")),
      );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrdersFromApi,
              color: const Color.fromARGB(
                  255, 29, 108, 92), // Match TransactionDetailPage color
              backgroundColor: Colors.white,
              child: orders.isEmpty
                  ? Center(
                      child: Text(
                        "No_orders_found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ).tr(),
                    )
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return InkWell(
                          onTap: () {
                            final selectedOrder = orders[index];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailPage(order: selectedOrder),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color.fromARGB(215, 223, 241, 223),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// LEFT SIDE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${order['orderId']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${order['booked']}",
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 10),
                                      if (order['status']
                                              .toString()
                                              .toLowerCase() ==
                                          'accepted') ...[
                                        Text(
                                          "${order['full_name']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${order['phone']}",
                                          style: const TextStyle(
                                              color: Colors.black87),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Text(
                                        "${order['machinery']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${order['workType']}",
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// RIGHT SIDE
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Text(
                                        "Status: ${order['status']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1D6C5C),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    /// TEMP IMAGE (replace later if needed)
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.transparent,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: (machineImages[order['machinery']
                                        .toString()
                                        .toLowerCase()] != 
                                        null &&
                                        machineImages[order['machinery']
                                        .toString()
                                        .toLowerCase()] !
                                        .isNotEmpty)
                                        ? Image.network(
                                          machineImages[order['machinery']
                                          .toString()
                                          .toLowerCase()] !,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.agriculture),
                                        )
                                        : const Icon(Icons.agriculture),
                                      ) 
                                    ),
                                  ],
                                ),
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
