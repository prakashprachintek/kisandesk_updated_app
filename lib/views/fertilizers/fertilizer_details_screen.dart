import 'package:flutter/material.dart';
import '../services/user_session.dart';
import 'fertilizer_model.dart';
import 'cart_service.dart';
import 'cart_screen.dart';
import 'address_screen.dart';
import 'my_fertilizer_orders_screen.dart'; // Create this next — I'll help you!

class FertilizerDetailsScreen extends StatefulWidget {
  final Fertilizer fertilizer;

  const FertilizerDetailsScreen({Key? key, required this.fertilizer})
      : super(key: key);

  @override
  State<FertilizerDetailsScreen> createState() =>
      _FertilizerDetailsScreenState();
}

class _FertilizerDetailsScreenState extends State<FertilizerDetailsScreen> {
  int _quantity = 1;
  late final int _maxAvailable = widget.fertilizer.availableQuantity;
  late Future<Cart> _cartFuture;
  late String _farmerId;

  @override
  void initState() {
    super.initState();
    _farmerId = UserSession.userId!;
    _cartFuture = CartService().getCart();
  }

  void _updateQuantity(int delta) {
    setState(() {
      final newQty = _quantity + delta;
      if (newQty >= 1 && newQty <= _maxAvailable) {
        _quantity = newQty;
      }
    });
  }

  // Add to existing cart
  Future<void> _addToCart() async {
    final item = CartItem(
      productId: widget.fertilizer.productId,
      quantity: _quantity,
      totalValue: widget.fertilizer.discountedPrice * _quantity,
    );

    await CartService().addToCart(item);
    setState(() => _cartFuture = CartService().getCart());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.fertilizer.productName} added to cart'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Buy Now → Creates temporary cart (safe for user)
  Future<void> _buyNow() async {
    final item = CartItem(
      productId: widget.fertilizer.productId,
      quantity: _quantity,
      totalValue: widget.fertilizer.discountedPrice * _quantity,
    );

    final tempCart = Cart(
      items: [item],
      totalCartValue: widget.fertilizer.discountedPrice * _quantity,
    );

    // Save to TEMP cart (main cart stays safe!)
    await CartService().setTempBuyNowCart(tempCart);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressScreen(isBuyNow: true),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int full = rating.floor();
    bool half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full)
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        if (i == full && half)
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fertilizer;
    final isOutOfStock = f.availableQuantity <= 0;
    final reviews = f.reviews ?? [];
    final details = f.productDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          // Cart Icon with Live Badge
          FutureBuilder<Cart>(
            future: _cartFuture,
            builder: (context, snapshot) {
              final itemCount = snapshot.data?.items.length ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text('$itemCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                    ),
                ],
              );
            },
          ),

          // My Orders Icon
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Orders',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyFertilizerOrdersScreen(farmerId: _farmerId))),
          ),
          const SizedBox(width: 8),
        ],
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
                  ? Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 80))
                  : PageView.builder(
                      itemCount: f.images.length,
                      itemBuilder: (context, index) => Image.network(
                        f.images[index].url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.error, size: 60),
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.productName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (f.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(f.category.capitalize(),
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 12),

                  // Price Row
                  Row(
                    children: [
                      if (f.mrp > f.sell)
                        Text('M.R.P ',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                )),
                      if (f.mrp > f.sell)
                        Text('₹${f.mrp.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough)),
                      if (f.mrp > f.sell) const SizedBox(width: 10),
                      Text('₹${f.discountedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (f.discountPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('${f.specialDiscount} OFF',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        isOutOfStock
                            ? Icons.error_outline
                            : Icons.inventory_2_outlined,
                        color: isOutOfStock ? Colors.red : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOutOfStock
                            ? 'Out of Stock'
                            : f.availableQuantity <= 20
                                ? 'Only ${f.availableQuantity} left!'
                                : 'In Stock • ${f.availableQuantity} available',
                        style: TextStyle(
                          fontSize: 14,
                          color: isOutOfStock
                              ? Colors.red
                              : (f.availableQuantity <= 20
                                  ? Colors.orange[700]
                                  : Colors.green),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('Pack Size: ${f.unit}',
                      style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  // Product Details
                  if (details != null && details.content.trim().isNotEmpty) ...[
                    const Text('Product Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(details.content,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // QUANTITY + BUTTONS
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? () => _updateQuantity(-1)
                                    : null),
                            SizedBox(
                              width: 40,
                              child: Text('$_quantity',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _quantity < f.availableQuantity
                                    ? () => _updateQuantity(1)
                                    : null),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 29, 108, 92),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Add to Cart',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : _buyNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Buy Now',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

    /*
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CartScreen())),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color.fromARGB(255, 29, 108, 92), width: 2),
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Go to Cart',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 29, 108, 92),
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  

                  const SizedBox(height: 32),
                  */

                  // === ALL YOUR REVIEWS CODE BELOW (unchanged & perfect) ===
                  if (reviews.isNotEmpty) ...[
                    const Divider(height: 40, thickness: 1),
                    const Text('Customer Reviews',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildRatingStars(reviews
                                .map((r) => double.tryParse(r.rating) ?? 0)
                                .reduce((a, b) => a + b) /
                            reviews.length),
                        const SizedBox(width: 10),
                        Text(
                          '${(reviews.map((r) => double.tryParse(r.rating) ?? 0).reduce((a, b) => a + b) / reviews.length).toStringAsFixed(1)} out of 5',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                            '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...reviews.take(3).map((review) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.green.shade100,
                                      child: Text(
                                        review.farmer.isNotEmpty
                                            ? review.farmer[0].toUpperCase()
                                            : 'A',
                                        style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(review.farmer,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15))),
                                    _buildRatingStars(
                                        double.tryParse(review.rating) ?? 0),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(review.comment,
                                    style: const TextStyle(
                                        fontSize: 14.5, height: 1.5)),
                              ],
                            ),
                          ),
                        )),
                    if (reviews.length > 3)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('More reviews coming soon!')));
                          },
                          child: Text('View all ${reviews.length} reviews',
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
  }
}
