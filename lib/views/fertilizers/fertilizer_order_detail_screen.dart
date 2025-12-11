import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mainproject1/views/services/pdf_generator.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Order #${order.orderId}'),
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
      tooltip: 'Download_Invoice'.tr(),
      onPressed: () => generateAndSaveInvoice(context, order),
    ),
    if (order.status == 'Pending')
      IconButton(
        icon: const Icon(Icons.cancel_outlined),
        onPressed: () {},
      ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Order Summary Card ===
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderId,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.formatDate(),
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text(
                            order.status,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: order.status == 'Pending'
                              ? Colors.orange.shade100
                              : order.status == 'Delivered'
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: order.status == 'Pending'
                                ? Colors.orange.shade900
                                : order.status == 'Delivered'
                                    ? Colors.green.shade900
                                    : Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total_Amount', style: TextStyle(fontSize: 18)).tr(),
                        Text(
                          '₹${order.amount}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Farmer Info Card ===
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.person, color: Colors.green),
                ),
                title: Text(
                  order.farmerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(order.farmerPhone),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(order.farmerVillage),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _launchPhone(order.farmerPhone),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // === Products Header ===
            const Text(
              'Products_Ordered',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ).tr(),
            const SizedBox(height: 12),

            // === Products List ===
            ...List.generate(order.productNames.length, (index) {
              final name = order.productNames[index];
              final qty = int.tryParse(order.productQuantities[index]) ?? 0;
              final price = double.tryParse(order.sellPrices[index]) ?? 0.0;
              final subtotal = qty * price;
              final category = order.productCategories[index];
              final images = order.productImages.length > index ? order.productImages[index] : <FertilizerImage>[];
              final detail = order.productDetails.length > index ? order.productDetails[index] : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Images (Horizontal scroll if multiple)
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: images.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.medication, size: 50, color: Colors.grey),
                                  )
                                : PageView.builder(
                                    itemCount: images.length,
                                    itemBuilder: (_, i) => ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        images[i].url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category,
                                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$qty × ₹$price = ₹$subtotal',
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

                      if (detail != null) ...[
                        const Divider(height: 30),
                        const Text('Usage_Instructions', style: TextStyle(fontWeight: FontWeight.w600)).tr(),
                        const SizedBox(height: 6),
                        Text(
                          detail.usage,
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                        if (detail.content.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Description:', style: TextStyle(fontWeight: FontWeight.w600)).tr(),
                          const SizedBox(height: 6),
                          Text(detail.content),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}