import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mainproject1/views/services/pdf_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_model.dart';

class FertilizerOrderDetailsScreen extends StatelessWidget {
  final RichFertilizerOrder order;

  const FertilizerOrderDetailsScreen({Key? key, required this.order})
      : super(key: key);

  // Helper to launch phone dialer
  void _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Updated cancel action with real API call
  Future<void> _onCancelOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel_Order'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            'Are_you_sure_cancel_order'
                .tr(namedArgs: {'orderId': order.orderId}),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Yes_Cancel'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await FertilizerApiService().cancelFertilizerOrder(
        orderId: order.id,
      );

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Order cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange.shade700;
      case 'Delivered':
        return Colors.green.shade700;
      case 'Shipped':
        return Colors.blue.shade700;
      default:
        return Colors.purple.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPending = order.status == 'Pending';
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderId}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Order Summary Card ===
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderId,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.formatDate(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(order.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(order.status)
                                  .withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Divider(
                      thickness: 1,
                      color: Colors.grey.shade300,
                    ),

                    const SizedBox(height: 10),

                    // Bottom section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total_Amount'.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (order.status == 'Pending' || order.status == 'Out for Delivery' || order.status == 'Delivered') ...[
                              GestureDetector(
                                onTap: () =>
                                    generateAndSaveInvoice(context, order),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.cyan.shade300),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.picture_as_pdf,
                                          color: Colors.cyan.shade700,
                                          size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Download Invoice',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.cyan.shade800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${order.amount}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (order.status == 'Pending') ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => _onCancelOrder(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.red.shade300),
                                  ),
                                  child: Text(
                                    'Cancel Order',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Farmer & Delivery Info Card ===
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      'Delivering to', // Heading for the card
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.person,
                          color: Colors.green, size: 30),
                    ),
                    title: Text(
                      order.farmerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(order.farmerPhone),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.deliveryAddress,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // === Products Header ===
            Text(
              'Products_Ordered'.tr(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // === Products List (Now using new nested structure) ===
            ...order.products.map((orderItem) {
              final product = orderItem.product;
              final qty = int.tryParse(orderItem.quantity) ?? 1;
              final price = product.sell;
              final subtotal = qty * price;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Images Carousel (Horizontal scroll if multiple)
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: product.images.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.medication,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  )
                                : PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: product.images.length,
                                    itemBuilder: (context, i) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          product.images[i].url,
                                          fit: BoxFit.cover,
                                          width: 110,
                                          height: 110,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.error,
                                                  color: Colors.red),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(width: 16),

                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.productName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.productCategory,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.unit,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$qty × ₹${product.sellPrice} = ₹${subtotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Product Details (Content & Usage)
                      if (product.productDetails.content.isNotEmpty ||
                          product.productDetails.usage.isNotEmpty) ...[
                        const Divider(height: 30),
                        if (product.productDetails.usage.isNotEmpty) ...[
                          Text(
                            'Usage_Instructions:'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.productDetails.usage,
                            style: const TextStyle(
                                color: Colors.blueGrey, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (product.productDetails.content.isNotEmpty) ...[
                          const Text(
                            'description',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ).tr(),
                          const SizedBox(height: 6),
                          Text(
                            product.productDetails.content,
                            style: const TextStyle(
                                color: Colors.blueGrey, fontSize: 14),
                          ),
                        ],
                      ],

                      // Full Description (from product_descriptions)
                      if (product.productDescriptions != null &&
                          product.productDescriptions!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Full_Description'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.productDescriptions!,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
