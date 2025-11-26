import 'package:flutter/material.dart';
import '../services/user_session.dart';
import 'address_service.dart';
import 'address_model.dart';
import 'add_address_screen.dart';
import 'cart_service.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_list_screen.dart';
import 'fertilizer_model.dart';

enum PaymentMethod { cod, online }

class AddressScreen extends StatefulWidget {
  final bool isBuyNow;
  const AddressScreen({Key? key, this.isBuyNow = false}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<Cart> _cartFuture;
  bool _isLoading = false;
  PaymentMethod _paymentMethod = PaymentMethod.cod;

  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _cartFuture = widget.isBuyNow
        ? CartService().getTempBuyNowCart()
        : CartService().getCart();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoadingAddresses = true);
    final addresses = await AddressService.getAddresses();
    final defaultAddr = await AddressService.getDefaultAddress();

    setState(() {
      _addresses = addresses;
      _selectedAddress = defaultAddr ?? (addresses.isNotEmpty ? addresses[0] : null);
      _isLoadingAddresses = false;
    });

    // If no addresses → go to add address screen
    if (_addresses.isEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
      });
    }
  }

  void _selectAddress(Address addr) async {
    setState(() => _selectedAddress = addr);
    await AddressService.setDefaultAddress(addr.id);
  }

  String get _deliveryAddress => _selectedAddress != null
      ? "${_selectedAddress!.houseDetails}, ${_selectedAddress!.village}, ${_selectedAddress!.taluka}, ${_selectedAddress!.district}, ${_selectedAddress!.state} - ${_selectedAddress!.pincode}"
      : "No address selected";

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cart = widget.isBuyNow
          ? await CartService().getTempBuyNowCart()
          : await CartService().getCart();

      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
        return;
      }

      final userId = UserSession.userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login')));
        return;
      }

      final response = await FertilizerApiService().bookFertilizerOrder(
        userId: userId,
        products: cart.items.map((i) => {'id': i.productId, 'quantity': i.quantity.toString()}).toList(),
        amount: cart.totalCartValue.toStringAsFixed(0),
        address: _deliveryAddress,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        if (widget.isBuyNow) {
          await CartService().clearTempBuyNowCart();
        } else {
          await CartService().clearCart();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_paymentMethod == PaymentMethod.cod
                ? 'Order placed! Pay ₹${cart.totalCartValue.toStringAsFixed(0)} on delivery'
                : 'Order placed successfully!'),
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
          SnackBar(content: Text(response['message'] ?? 'Order failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery & Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = snapshot.data ?? Cart(items: [], totalCartValue: 0.0);
          final totalAmount = cart.items.fold(0.0, (sum, i) => sum + i.totalValue);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Summary
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${cart.items.length} item${cart.items.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            const Text('Total Payable', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                        Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Select Address Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Address', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () async {
                        final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
                        if (added == true) _loadAddresses();
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      label: const Text('Add New', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Addresses List
                _isLoadingAddresses
                    ? const Center(child: CircularProgressIndicator())
                    : _addresses.isEmpty
                        ?  Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No saved addresses. Tap "Add New" to save one!', style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          )
                        : Column(
                            children: _addresses.map((addr) {
                              final isSelected = _selectedAddress?.id == addr.id;
                              return Card(
                                elevation: isSelected ? 8 : 3,
                                color: isSelected ? Colors.green.shade50 : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
                                ),
                                child: RadioListTile<Address>(
                                  title: Text(addr.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(addr.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      Text(addr.phone, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  secondary: addr.isDefault ? const Icon(Icons.star, color: Colors.amber) : null,
                                  value: addr,
                                  groupValue: _selectedAddress,
                                  onChanged: (val) => _selectAddress(val!),
                                ),
                              );
                            }).toList(),
                          ),

                const SizedBox(height: 32),

                // Payment Method
                const Text('Payment Method', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      RadioListTile<PaymentMethod>(
                        title: const Text('Cash on Delivery (COD)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Pay when product is delivered'),
                        secondary: const Icon(Icons.payments, color: Colors.green, size: 28),
                        value: PaymentMethod.cod,
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      const Divider(height: 1),
                      RadioListTile<PaymentMethod>(
                        title: const Text('Online Payment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        subtitle: const Text('UPI • Card • Netbanking'),
                        secondary: const Icon(Icons.credit_card, color: Colors.blue, size: 28),
                        value: PaymentMethod.online,
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _paymentMethod == PaymentMethod.cod
                                ? 'Place Order • Pay on Delivery'
                                : 'Pay ₹${totalAmount.toStringAsFixed(0)} Online',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}