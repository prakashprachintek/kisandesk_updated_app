import 'package:flutter/material.dart';
import '../services/user_session.dart';
import 'cart_service.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_list_screen.dart';
import 'fertilizer_model.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<Cart> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = CartService().getCart();
  }

  Future<void> _placeOrder() async {
    try {
      final cart = await CartService().getCart();
      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart is empty')),
        );
        return;
      }

      final userId = UserSession.userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to place an order')),
        );
        return;
      }

      final response = await FertilizerApiService().bookFertilizerOrder(
        userId: userId,
        products: cart.items
            .map((item) => {'id': item.productId, 'quantity': item.quantity.toString()})
            .toList(),
        amount: cart.totalCartValue.toString(),
      );

      if (response['status'] == 'success') {
        await CartService().clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FertilizerListScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Address', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          final isCartEmpty = snapshot.hasData && snapshot.data!.items.isEmpty;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  'Address selection will be implemented later',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: isCartEmpty ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}