import 'package:flutter/material.dart';
import '../services/user_session.dart';
import 'cart_service.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_list_screen.dart';
import 'fertilizer_model.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<Cart> _cartFuture;
  bool _isLoading = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _villageController;
  late TextEditingController _taluqController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _cartFuture = CartService().getCart();

    // Initialize controllers with user data
    final user = UserSession.user;
    _nameController = TextEditingController(text: user?['full_name'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
    _villageController = TextEditingController(text: user?['village'] ?? '');
    _taluqController = TextEditingController(text: user?['taluka'] ?? '');
    _districtController = TextEditingController(text: user?['district'] ?? '');
    _stateController = TextEditingController(text: user?['state'] ?? '');
    _pincodeController = TextEditingController(text: user?['pincode'] ?? '');
    _addressController = TextEditingController(text: user?['address'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _taluqController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _getFullAddress() {
    return [
      _addressController.text.trim(),
      _villageController.text.trim(),
      _taluqController.text.trim(),
      _districtController.text.trim(),
      _stateController.text.trim(),
      _pincodeController.text.trim(),
    ].where((s) => s.isNotEmpty).join(', ');
  }

  Future<void> _placeOrder() async {
    if (_isLoading) return;

    final fullAddress = _getFullAddress();
    if (fullAddress.isEmpty || fullAddress.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cart = await CartService().getCart();
      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      final userId = UserSession.userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final response = await FertilizerApiService().bookFertilizerOrder(
        userId: userId,
        products: cart.items
            .map((item) => {
                  'id': item.productId,
                  'quantity': item.quantity.toString(),
                })
            .toList(),
        amount: cart.totalCartValue.toStringAsFixed(0),
        address: fullAddress, // NEW: Sending full address
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        await CartService().clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FertilizerListScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          final cart = snapshot.data;
          final totalAmount = cart?.totalCartValue ?? 0.0;
          final itemCount = cart?.items.length ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$itemCount item${itemCount == 1 ? '' : 's'} in cart', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Total Amount', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text('Delivery Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Form Fields
                _buildTextField(_nameController, 'Full Name', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(_addressController, 'House No., Street, Landmark', Icons.home),
                const SizedBox(height: 12),
                _buildTextField(_villageController, 'Village', Icons.location_city),
                const SizedBox(height: 12),
                _buildTextField(_taluqController, 'Taluq / Tehsil', Icons.maps_ugc),
                const SizedBox(height: 12),
                _buildTextField(_districtController, 'District', Icons.location_on),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_stateController, 'State', Icons.public)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_pincodeController, 'Pincode', Icons.pin_drop, keyboardType: TextInputType.number)),
                  ],
                ),

                const SizedBox(height: 32),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (itemCount == 0 || _isLoading) ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 29, 108, 92)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 29, 108, 92), width: 2),
        ),
      ),
    );
  }
}