import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mainproject1/views/machinery/order_detail_page.dart';
import 'package:mainproject1/views/machinery/myorderspage.dart';
import '../services/user_session.dart';
import '../services/api_config.dart';
import 'bookpage.dart';
import 'orderTransactionTab.dart';
import 'package:mainproject1/views/profile/personalDetailsPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'machine_selection_page.dart';

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
  Map<String, String> machineImages = {};
  bool isMachineLoading = true;

  List<Map<String, String>> recentOrders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecentOrders();
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
          final name = (m["name_in_english"] ?? m["name"] ?? "")
              .toString()
              .toLowerCase()
              .trim();
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
        setState(() => isMachineLoading = false);
      }
    } catch (e) {
      setState(() => isMachineLoading = false);
    }
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
              "machinery": item['machinery_type']?.toString() ?? 'Unknown',
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
            errorMessage =
                recent.isEmpty ? "No_recent_orders_found.".tr() : null;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = json['message'] ?? "Failed_to_fetch_orders".tr();
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Server error: ${response.statusCode}".tr();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error fetching orders: $e".tr();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Machinery_Rent".tr(),
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
                    _buildTile(context,
                        icon: Icons.shopping_cart,
                        label: tr("Book"),
                        color: Colors.green, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MachineSelectionPage(),
                        ),
                      );
                    } // Updated to check profile
                        ),
                    _buildTile(
                      context,
                      icon: Icons.list_alt,
                      label: tr("My_Orders"),
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
                  tr("Recent_Orders"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(child: Text(tr(errorMessage!)))
                        : recentOrders.isEmpty
                            ? Center(child: Text(tr("No_recent_orders_found")))
                            : ListView.builder(
                                itemCount: recentOrders.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final order = recentOrders[index];

                                  return InkWell(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderDetailPage(order: order),
                                        ),
                                      );
                                      if (result == true) {
                                        _fetchRecentOrders();
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// LEFT SIDE
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /// ORDER ID
                                                Text(
                                                  "${order['orderId']}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                /// DATE
                                                Text(
                                                  "${order['date']}",
                                                  style: const TextStyle(
                                                      color: Colors.black54),
                                                ),

                                                /// OWNER ONLY IF ACCEPTED
                                                if (order['status']
                                                        .toString()
                                                        .toLowerCase() ==
                                                    'accepted') ...[
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    "${order['name']}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${order['phone']}",
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],

                                                const SizedBox(height: 10),

                                                /// MACHINE
                                                Text(
                                                  "${order['machinery']}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                /// WORK TYPE
                                                Text(
                                                  "${order['workType']}",
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          /// RIGHT SIDE
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              /// STATUS
                                              Text(
                                                "${order['status']}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1D6C5C),
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              /// IMAGE (STATIC FOR NOW — same as your current)
                                              Container(
                                                height: 60,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.transparent,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Builder(
                                                    builder: (_) {
                                                      final key =
                                                          order['machinery']
                                                              .toString()
                                                              .toLowerCase()
                                                              .trim();

                                                      final imageUrl =
                                                          machineImages[key];

                                                      return (imageUrl !=
                                                                  null &&
                                                              imageUrl
                                                                  .isNotEmpty)
                                                          ? Image.network(
                                                              imageUrl,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_,
                                                                      __,
                                                                      ___) =>
                                                                  const Icon(Icons
                                                                      .agriculture),
                                                            )
                                                          : const Icon(Icons
                                                              .agriculture);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
