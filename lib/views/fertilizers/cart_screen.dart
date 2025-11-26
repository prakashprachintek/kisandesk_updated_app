import 'package:flutter/material.dart';
import 'fertilizer_model.dart';
import 'fertilizer_api_service.dart';
import 'cart_service.dart';
import 'address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<FertilizerResponse> _fertilizerFuture;
  late Future<Cart> _cartFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _fertilizerFuture = FertilizerApiService().fetchFertilizers();
    _cartFuture = CartService().getCart();
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) return;

    final fertilizers = (await _fertilizerFuture).results;
    final fertilizer = fertilizers.firstWhere(
      (f) => f.productId == productId,
      orElse: () => Fertilizer(
        id: '',
        productName: 'Product Not Found',
        mrpPrice: '0',
        sellPrice: '0',
        productQuantity: '1',
        productUnit: 'Unit',
        productId: productId,
        soldQuantity: '0',
        availableQuantity: 0,
        status: 'Unknown',
        images: [],
        isDeleted: true,
        createdAt: '',
        createdBy: '',
        category: 'Unknown',
      ),
    );

    if (newQuantity > fertilizer.availableQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${fertilizer.availableQuantity} unit${fertilizer.availableQuantity == 1 ? '' : 's'} available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await CartService().updateQuantity(productId, newQuantity);
    setState(() => _refreshData());
  }

  Future<void> _removeItem(String productId) async {
    await CartService().removeFromCart(productId);
    setState(() => _refreshData());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from cart'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_fertilizerFuture, _cartFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          final fertilizers = snapshot.data![0] as FertilizerResponse;
          final cart = snapshot.data![1] as Cart;

          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 90, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Explore products and add to cart!', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          final fertilizerMap = {for (var f in fertilizers.results) f.productId: f};

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final fertilizer = fertilizerMap[item.productId] ?? Fertilizer(
                      id: '',
                      productName: 'Product Not Found',
                      mrpPrice: '0',
                      sellPrice: '0',
                      productQuantity: '1',
                      productUnit: 'Unit',
                      productId: item.productId,
                      soldQuantity: '0',
                      availableQuantity: 0,
                      status: 'Unknown',
                      images: [],
                      isDeleted: true,
                      createdAt: '',
                      createdBy: '',
                      category: 'Unknown',
                    );

                    final unitPrice = fertilizer.discountedPrice;
                    final isOutOfStock = fertilizer.availableQuantity <= 0;
                    final canIncrease = item.quantity < fertilizer.availableQuantity;

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                            child: Container(
                              width: 110,
                              height: 110,
                              color: Colors.grey[200],
                              child: fertilizer.images.isNotEmpty
                                  ? Image.network(
                                      fertilizer.images[0].url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40),
                                    )
                                  : const Icon(Icons.image_not_supported, size: 40),
                            ),
                          ),

                          // Product Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fertilizer.productName,
                                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // MRP + Discounted Price + Discount Badge
                                  Row(
                                    children: [
                                      if (fertilizer.mrp > fertilizer.sell)
                                        Text(
                                          '₹${fertilizer.mrp.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                        ),
                                      if (fertilizer.mrp > fertilizer.sell) const SizedBox(width: 8),
                                      Text(
                                        '₹${unitPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                      if (fertilizer.discountPercent > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(6)),
                                            child: Text(
                                              '${fertilizer.specialDiscount} OFF',
                                              style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),
                                  Text(
                                    'per ${fertilizer.unit}', // Now shows "500 Gm", "1 Ltr"
                                    style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                                  ),

                                  const SizedBox(height: 10),

                                  // Quantity Controls
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 28),
                                        onPressed: item.quantity > 1 ? () => _updateQuantity(item.productId, item.quantity - 1) : null,
                                        color: item.quantity > 1 ? Colors.red.shade600 : Colors.grey,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline, size: 28, color: canIncrease ? Colors.green : Colors.grey),
                                        onPressed: canIncrease ? () => _updateQuantity(item.productId, item.quantity + 1) : null,
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                                        onPressed: () => _removeItem(item.productId),
                                      ),
                                    ],
                                  ),

                                  // Stock Warning
                                  if (!canIncrease || isOutOfStock)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        isOutOfStock ? 'Out of stock' : 'Max available: ${fertilizer.availableQuantity}',
                                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Total & Checkout Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: const Offset(0, -4))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                        Text(
                          '₹${cart.totalCartValue.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                        ),
                        child: const Text('Proceed to Address', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}