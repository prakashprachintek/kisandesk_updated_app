import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'fertilizer_model.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_order_detail_screen.dart';

class MyFertilizerOrdersScreen extends StatefulWidget {
  final String farmerId;
  const MyFertilizerOrdersScreen({Key? key, required this.farmerId})
      : super(key: key);

  @override
  State<MyFertilizerOrdersScreen> createState() =>
      _MyFertilizerOrdersScreenState();
}

class _MyFertilizerOrdersScreenState extends State<MyFertilizerOrdersScreen> {
  late Future<RichFertilizerOrderResponse> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _ordersFuture =
          FertilizerApiService().fetchFertilizerOrders(widget.farmerId);
    });
  }

  Future<void> _onRefresh() async {
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My_Fertilizer_Orders'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.green,
        child: FutureBuilder<RichFertilizerOrderResponse>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error_loading_orders'.tr(),
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadOrders,
                        icon: const Icon(Icons.refresh),
                        label: Text('Retry'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
              return Center(
                child: Text(
                  'No_orders_yet'.tr(),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final orders = snapshot.data!.results;

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return InkWell(
                  onTap: () async {
                    final bool? cancelled = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FertilizerOrderDetailsScreen(order: order),
                      ),
                    );

                    if (cancelled == true) {
                      _loadOrders();
                    }
                  },
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Order ID + Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                order.formatDate(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Farmer & Village
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                order.farmerName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Text(
                                order.farmerVillage,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Delivery Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  order.deliveryAddress,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 24),

                          // NEW: Just show number of items instead of full product list
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${order.products.length} ${order.products.length == 1 ? 'item' : 'items'}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ).tr(),
                            ],
                          ),

                          const Divider(height: 24),

                          // Total & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ₹${order.amount}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Chip(
                                label: Text(order.status),
                                backgroundColor: order.status == 'Pending'
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                                labelStyle: TextStyle(
                                  color: order.status == 'Pending'
                                      ? Colors.orange.shade900
                                      : Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
      ),
    );
  }
}