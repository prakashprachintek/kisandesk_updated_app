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
        id: '', productName: 'Unknown', mrpPrice: '0', sellPrice: '0',
        specialDiscount: '0%', unit: '', productId: productId, soldQuantity: '0',
        totalQuantity: 0, status: '', images: [], isDeleted: false,
        createdAt: '', createdBy: '', category: '',
      ),
    );

    if (newQuantity > fertilizer.totalQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${fertilizer.totalQuantity} units available in stock')),
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
      const SnackBar(content: Text('Item removed from cart')),
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
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Add products to get started!', style: TextStyle(color: Colors.grey)),
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
                      id: '', productName: 'Product Not Found', mrpPrice: '0', sellPrice: '0',
                      specialDiscount: '0%', unit: '', productId: item.productId,
                      soldQuantity: '0', totalQuantity: 0, status: '', images: [], isDeleted: true,
                      createdAt: '', createdBy: '', category: '',
                    );

                    final unitPrice = fertilizer.discountedPrice;
                    final isOutOfStock = fertilizer.totalQuantity <= 0;
                    final canIncrease = item.quantity < fertilizer.totalQuantity;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                            child: Container(
                              width: 110,
                              height: 110,
                              color: Colors.grey[200],
                              child: fertilizer.images.isNotEmpty
                                  ? Image.network(fertilizer.images[0].url, fit: BoxFit.cover)
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
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // MRP + Final Price
                                  Row(
                                    children: [
                                      if (fertilizer.mrpPrice != fertilizer.sellPrice)
                                        Text(
                                          '₹${fertilizer.mrpPrice}',
                                          style: const TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                        ),
                                      if (fertilizer.mrpPrice != fertilizer.sellPrice) const SizedBox(width: 6),
                                      Text(
                                        '₹${unitPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                      if (fertilizer.specialDiscount != '0%')
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                                            child: Text('${fertilizer.specialDiscount} OFF', style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                    ],
                                  ),

                                  Text('per ${fertilizer.unit}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),

                                  const SizedBox(height: 8),

                                  // Quantity Controls
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: item.quantity > 1 ? () => _updateQuantity(item.productId, item.quantity - 1) : null,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline, color: canIncrease ? Colors.green : Colors.grey),
                                        onPressed: canIncrease ? () => _updateQuantity(item.productId, item.quantity + 1) : null,
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _removeItem(item.productId),
                                      ),
                                    ],
                                  ),

                                  // Stock Warning
                                  if (!canIncrease && item.quantity >= fertilizer.totalQuantity)
                                    Text(
                                      fertilizer.totalQuantity <= 0 ? 'Out of stock' : 'Max stock reached',
                                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
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

              // Total & Checkout
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                          '₹${cart.totalCartValue.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Proceed to Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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