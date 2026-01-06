import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_model.dart';

class DeliveryRequestDetailsScreen extends StatelessWidget {
  final RichFertilizerOrder order;

  const DeliveryRequestDetailsScreen({Key? key, required this.order})
      : super(key: key);

  // Extract customer name + phone from the second line of delivery_address
  String _extractCustomerLine() {
    final lines = order.deliveryAddress.split('\n');
    if (lines.length >= 2) {
      return lines[1].trim(); // e.g., "shivashankar | 7411317178"
    }
    return 'Customer';
  }

  // Extract phone number after the "|" symbol
  String _extractPhoneNumber() {
    final customerLine = _extractCustomerLine();
    final parts = customerLine.split('|');
    if (parts.length >= 2) {
      return parts[1].trim();
    }
    return '';
  }

  // Extract customer name (before "|")
  String _extractCustomerName() {
    final customerLine = _extractCustomerLine();
    final parts = customerLine.split('|');
    return parts.isNotEmpty ? parts[0].trim() : 'Customer';
  }

  // Extract location (first line)
  String _extractLocation() {
    final lines = order.deliveryAddress.split('\n');
    return lines.isNotEmpty ? lines.first.trim() : 'Location not available';
  }

  // Launch phone dialer
  Future<void> _launchPhone(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Placeholder for future action
  void _onMarkAsDelivered(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delivery'.tr()),
        content: Text(
            'Are you sure this order has been delivered to the customer?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yes, Delivered'.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marking as delivered...'.tr())),
    );

    try {
      final response =
          await FertilizerApiService().markAsDelivered(orderId: order.id);

      // Success!
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response['message'] ?? 'Order marked as delivered!'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to list and signal refresh
      Navigator.pop(context, true); // true = refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Out for Delivery':
        return Colors.blue.shade700;
      case 'Delivered':
        return Colors.green.shade700;
      case 'Pending':
        return Colors.orange.shade700;
      default:
        return Colors.purple.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = _extractPhoneNumber();
    final customerName = _extractCustomerName();

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery #${order.orderId}'),
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
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderId,
                              style: const TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.formatDate(),
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
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
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const SizedBox(height: 16),
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
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${order.amount}',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ),

                        // Mark as Delivered Button
                        // Inside the Row with Total Amount
                        if (order.status !=
                            'Delivered') // Only show if not already delivered
                          GestureDetector(
                            onTap: () => _onMarkAsDelivered(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.green.shade400, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_shipping,
                                      color: Colors.green.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mark as Delivered'.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Delivered'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Customer & Delivery Info Card ===
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.shade100,
                  child:
                      const Icon(Icons.person, color: Colors.green, size: 30),
                ),
                title: Text(
                  customerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (phone.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(phone),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _extractLocation(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: phone.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.call,
                            color: Colors.green, size: 28),
                        onPressed: () => _launchPhone(phone),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            // === Products Header ===
            Text(
              'Products_to_Deliver'
                  .tr(), // or 'Products_Ordered'.tr() if you prefer
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // === Products List (unchanged — already perfect!) ===
            ...order.products.map((orderItem) {
              final product = orderItem.product;
              final qty = int.tryParse(orderItem.quantity) ?? 1;
              final subtotal = qty * product.sell;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: product.images.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.medication,
                                        size: 50, color: Colors.grey),
                                  )
                                : PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: product.images.length,
                                    itemBuilder: (context, i) => ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        product.images[i].url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.error,
                                                color: Colors.red),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.productName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(product.productCategory,
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic)),
                                const SizedBox(height: 6),
                                Text(product.unit,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 10),
                                Text(
                                  '$qty × ₹${product.sellPrice} = ₹${subtotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (product.productDetails.content.isNotEmpty ||
                          product.productDetails.usage.isNotEmpty) ...[
                        const Divider(height: 30),
                        if (product.productDetails.usage.isNotEmpty) ...[
                          Text('Usage_Instructions:'.tr(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(product.productDetails.usage,
                              style: const TextStyle(
                                  color: Colors.blueGrey, fontSize: 14)),
                          const SizedBox(height: 12),
                        ],
                        if (product.productDetails.content.isNotEmpty) ...[
                          const Text('description',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15))
                              .tr(),
                          const SizedBox(height: 6),
                          Text(product.productDetails.content,
                              style: const TextStyle(
                                  color: Colors.blueGrey, fontSize: 14)),
                        ],
                      ],
                      if (product.productDescriptions != null &&
                          product.productDescriptions!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Full_Description'.tr(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text(product.productDescriptions!,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 14)),
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
