import 'package:flutter/material.dart';
import 'fertilizer_model.dart';
import 'fertilizer_api_service.dart';
import 'cart_service.dart';
import 'address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<FertilizerResponse> _fertilizerFuture;
  late Future<Cart> _cartFuture;

  @override
  void initState() {
    super.initState();
    _fertilizerFuture = FertilizerApiService().fetchFertilizers();
    _cartFuture = CartService().getCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([_fertilizerFuture, _cartFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final fertilizerResponse = snapshot.data![0] as FertilizerResponse;
          final cart = snapshot.data![1] as Cart;
          final fertilizers = fertilizerResponse.results;

          if (cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cart.items.length + 1, // +1 for total and button
            itemBuilder: (context, index) {
              if (index < cart.items.length) {
                final cartItem = cart.items[index];
                final fertilizer = fertilizers.firstWhere(
                  (f) => f.productId == cartItem.productId,
                  orElse: () => Fertilizer(
                    id: '',
                    productName: 'Unknown Product',
                    amount: '0',
                    discount: '0%',
                    quantity: '0',
                    productId: cartItem.productId,
                    images: [],
                    isDeleted: true,
                    createdAt: '',
                    createdBy: '',
                  ),
                );
                final unitPrice = cartItem.totalValue / cartItem.quantity;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: fertilizer.images.isNotEmpty
                              ? Image.network(
                                  fertilizer.images[0].url,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fertilizer.productName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${unitPrice.toStringAsFixed(0)} each',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Total: ₹${cartItem.totalValue.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () async {
                                      if (cartItem.quantity > 1) {
                                        await CartService().updateQuantity(cartItem.productId, cartItem.quantity - 1);
                                        setState(() {
                                          _cartFuture = CartService().getCart();
                                        });
                                      }
                                    },
                                  ),
                                  Text(
                                    '${cartItem.quantity}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      await CartService().updateQuantity(cartItem.productId, cartItem.quantity + 1);
                                      setState(() {
                                        _cartFuture = CartService().getCart();
                                      });
                                    },
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await CartService().removeFromCart(cartItem.productId);
                                      setState(() {
                                        _cartFuture = CartService().getCart();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Display total cart value and Proceed to Address button
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Cart Value:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${cart.totalCartValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: cart.items.isNotEmpty
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddressScreen(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Proceed to Address',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}