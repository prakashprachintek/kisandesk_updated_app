import 'package:flutter/material.dart';
import 'fertilizer_model.dart';
import 'fertilizer_api_service.dart';

class MyFertilizerOrdersScreen extends StatefulWidget {
  final String farmerId;
  const MyFertilizerOrdersScreen({Key? key, required this.farmerId}) : super(key: key);

  @override
  State<MyFertilizerOrdersScreen> createState() => _MyFertilizerOrdersScreenState();
}

class _MyFertilizerOrdersScreenState extends State<MyFertilizerOrdersScreen> {
  late Future<RichFertilizerOrderResponse> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = FertilizerApiService().fetchFertilizerOrders(widget.farmerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fertilizer Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        // backgroundColor: Colors.green.shade700,
        // foregroundColor: Colors.white,
      ),
      body: FutureBuilder<RichFertilizerOrderResponse>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
            return const Center(
              child: Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          final orders = snapshot.data!.results;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            order.formatDate(),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Farmer Info
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(order.farmerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(order.farmerVillage, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Divider(height: 20),

                      // Products List
                      ...List.generate(order.productNames.length, (i) {
                        final name = order.productNames[i];
                        final qty = order.productQuantities[i];
                        final price = order.sellPrices[i];
                        final images = order.productImages.length > i ? order.productImages[i] : <FertilizerImage>[];
                        final detail = order.productDetails.length > i ? order.productDetails[i] : null;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: images.isNotEmpty
                                    ? Image.network(
                                        images[0].url,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
                                      )
                                    : const Icon(Icons.medication, size: 60, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('$qty units × ₹$price', style: const TextStyle(color: Colors.green)),
                                    if (detail != null)
                                      Text(
                                        detail.usage,
                                        style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(),

                      // Total & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ₹${order.amount}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          Chip(
                            label: Text(order.status),
                            backgroundColor: order.status == 'Pending' ? Colors.orange.shade100 : Colors.green.shade100,
                            labelStyle: TextStyle(
                              color: order.status == 'Pending' ? Colors.orange.shade900 : Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}