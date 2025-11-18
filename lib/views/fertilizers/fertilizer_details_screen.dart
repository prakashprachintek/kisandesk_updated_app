import 'package:flutter/material.dart';
import 'fertilizer_model.dart';
import 'cart_service.dart';
import 'cart_screen.dart';

class FertilizerDetailsScreen extends StatefulWidget {
  final Fertilizer fertilizer;

  const FertilizerDetailsScreen({Key? key, required this.fertilizer}) : super(key: key);

  @override
  State<FertilizerDetailsScreen> createState() => _FertilizerDetailsScreenState();
}

class _FertilizerDetailsScreenState extends State<FertilizerDetailsScreen> {
  late int _quantity = 1;
  static const int _maxQuantityPerOrder = 8;

  @override
  void initState() {
    super.initState();
    // Reset quantity when opening details (optional)
    _quantity = 1;
  }

  void _updateQuantity(int delta) {
    setState(() {
      final newQty = _quantity + delta;
      if (newQty >= 1 &&
          newQty <= _maxQuantityPerOrder &&
          newQty <= widget.fertilizer.totalQuantity) {
        _quantity = newQty;
      }
    });
  }

  Future<void> _addToCart({bool buyNow = false}) async {
    if (widget.fertilizer.totalQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is currently out of stock')),
      );
      return;
    }

    if (_quantity > widget.fertilizer.totalQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${widget.fertilizer.totalQuantity} units available')),
      );
      return;
    }

    final cartItem = CartItem(
      productId: widget.fertilizer.productId,
      quantity: _quantity,
      totalValue: widget.fertilizer.discountedPrice * _quantity,
    );

    if (buyNow) {
      await CartService().clearCart();
    }
    await CartService().addToCart(cartItem);

    final message = buyNow
        ? '${widget.fertilizer.productName} - Ready to buy!'
        : '${widget.fertilizer.productName} added to cart';

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (buyNow) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fertilizer;
    final isOutOfStock = f.totalQuantity <= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 240,
              width: double.infinity,
              child: f.images.isEmpty
                  ? Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 80))
                  : PageView.builder(
                      itemCount: f.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          f.images[index].url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 60),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    f.productName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Category Badge
                  if (f.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f.category.capitalize(),
                        style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Price Row
                  Row(
                    children: [
                      if (f.mrpPrice != f.sellPrice)
                        Text(
                          '₹${f.mrpPrice}',
                          style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough),
                        ),
                      if (f.mrpPrice != f.sellPrice) const SizedBox(width: 10),
                      Text(
                        '₹${f.discountedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (f.specialDiscount != '0%')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(6)),
                          child: Text('${f.specialDiscount} OFF', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        isOutOfStock ? Icons.error_outline : Icons.inventory_2_outlined,
                        color: isOutOfStock ? Colors.red : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOutOfStock
                            ? 'Out of Stock'
                            : f.totalQuantity <= 20
                                ? 'Only ${f.totalQuantity} left!'
                                : 'In Stock • ${f.totalQuantity} available',
                        style: TextStyle(
                          fontSize: 14,
                          color: isOutOfStock ? Colors.red : (f.totalQuantity <= 20 ? Colors.orange[700] : Colors.green),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Unit & Product ID
                  Text('Pack Size: ${f.unit}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Product ID: ${f.productId}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),

                  const SizedBox(height: 16),

                  // Description (if exists)
                  if (f.description != null && f.description!.trim().isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(f.description!, style: const TextStyle(fontSize: 15, height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // Quantity Selector + Buttons
                  Row(
                    children: [
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1 ? () => _updateQuantity(-1) : null,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: (_quantity < _maxQuantityPerOrder && _quantity < f.totalQuantity) ? () => _updateQuantity(1) : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Add to Cart Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : () => _addToCart(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Add to Cart', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Buy Now Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : () => _addToCart(buyNow: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Buy Now', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Go to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color.fromARGB(255, 29, 108, 92), width: 2),
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Go to Cart', style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 29, 108, 92), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}