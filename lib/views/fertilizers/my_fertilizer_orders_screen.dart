import 'package:flutter/material.dart';
import 'fertilizer_model.dart';
import 'fertilizer_api_service.dart';

class MyFertilizerOrdersScreen extends StatefulWidget {
  final String farmerId;

  const MyFertilizerOrdersScreen({Key? key, required this.farmerId}) : super(key: key);

  @override
  _MyFertilizerOrdersScreenState createState() => _MyFertilizerOrdersScreenState();
}

class _MyFertilizerOrdersScreenState extends State<MyFertilizerOrdersScreen> {
  late Future<FertilizerOrderResponse> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = FertilizerApiService().fetchFertilizerOrders(widget.farmerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<FertilizerOrderResponse>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!.results;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order.orderId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Products:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (order.products.isEmpty)
                        const Text(
                          'No products in this order',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        )
                      else
                        ...order.products.map((product) => Text(
                              'Product ID: ${product.id}, Quantity: ${product.quantity}',
                              style: const TextStyle(fontSize: 14),
                            )),
                      const SizedBox(height: 8),
                      Text(
                        'Amount: ₹${order.amount}',
                        style: const TextStyle(fontSize: 14, color: Colors.green),
                      ),
                      Text(
                        'Status: ${order.status}',
                        style: TextStyle(
                          fontSize: 14,
                          color: order.status == 'Pending' ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ordered on: ${order.activityLog.isNotEmpty ? order.activityLog[0].actionAt : 'N/A'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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