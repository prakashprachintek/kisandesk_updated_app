import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'fertilizer_delivery_request_details_screen.dart';
import 'fertilizer_model.dart';
import 'fertilizer_api_service.dart';

class DeliveryRequestsScreen extends StatefulWidget {
  final String deliveryPartnerId; // Changed from farmerId

  const DeliveryRequestsScreen({Key? key, required this.deliveryPartnerId})
      : super(key: key);

  @override
  State<DeliveryRequestsScreen> createState() => _DeliveryRequestsScreenState();
}

class _DeliveryRequestsScreenState extends State<DeliveryRequestsScreen> {
  late Future<RichFertilizerOrderResponse> _ordersFuture;

  // Filter state
  String _selectedFilter = 'Out for Delivery'; // Default filter

  final List<String> _filterOptions = [
    'All',
    'Out for Delivery'.tr(),
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    debugPrint('Delivery Partner ID: ${widget.deliveryPartnerId}');
    setState(() {
      _ordersFuture = FertilizerApiService()
          .fetchDeliveryPartnerOrders(widget.deliveryPartnerId);
    });
  }

  Future<void> _onRefresh() async {
    await _loadOrders();
  }

  // Helper methods (unchanged)
  String _extractCustomerLine(String address) {
    final lines = address.split('\n');
    if (lines.length >= 2) return lines[1].trim();
    return 'Customer_details_not_available'.tr();
  }

  String _extractLocationLine(String address) {
    final lines = address.split('\n');
    return lines.isNotEmpty ? lines.first.trim() : 'Location_not_available'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My_Deliveries'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // === Filter Chips ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(
                        filter.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.green.shade600,
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: isSelected ? Colors.green.shade600 : Colors.transparent,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // === Orders List ===
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.green,
              child: FutureBuilder<RichFertilizerOrderResponse>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(/* your error UI */);
                  }

                  if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No_deliveries_assigned'.tr(),
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Apply filter
                  var filteredOrders = snapshot.data!.results;
                  if (_selectedFilter != 'All') {
                    filteredOrders = filteredOrders
                        .where((order) => order.status == _selectedFilter)
                        .toList();
                  }

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${_selectedFilter.toLowerCase()} deliveries'.tr(),
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];

                      return InkWell(
                        onTap: () async {
                          final bool? refreshed = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeliveryRequestDetailsScreen(order: order),
                            ),
                          );

                          if (refreshed == true) {
                            _loadOrders(); // Refresh list after marking delivered
                          }
                        },
                        child: Card(
                          // ... your existing card UI (unchanged)
                          // Just copy-paste your current card code here
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    Text(order.formatDate(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _extractCustomerLine(order.deliveryAddress),
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _extractLocationLine(order.deliveryAddress),
                                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${order.products.length} ${order.products.length == 1 ? 'item' : 'items'}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ).tr(),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total: ₹${order.amount}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                    Chip(
                                      label: Text(order.status),
                                      backgroundColor: _getStatusColor(order.status),
                                      labelStyle: TextStyle(
                                        color: _getStatusTextColor(order.status),
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
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Out for Delivery':
        return Colors.blue.shade100;
      case 'Delivered':
        return Colors.green.shade100;
      case 'Pending':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Out for Delivery':
        return Colors.blue.shade900;
      case 'Delivered':
        return Colors.green.shade900;
      case 'Pending':
        return Colors.orange.shade900;
      default:
        return Colors.grey.shade900;
    }
  }
}