// lib/screens/address_screen.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mainproject1/views/fertilizers/fertilizer_offer_model.dart';
import 'package:mainproject1/views/home/HomePage.dart';
import '../services/user_session.dart';
import 'address_service.dart';
import 'address_model.dart';
import 'manage_address_screen.dart';
import 'cart_service.dart';
import 'fertilizer_api_service.dart';
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
  Address? _selectedAddress;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _cartFuture = widget.isBuyNow
        ? CartService().getTempBuyNowCart()
        : CartService().getCart();
    _initializeDefaultAddress();
    _offersFuture = FertilizerApiService().fetchFertilizerOffers();
  }

  Future<void> _initializeDefaultAddress() async {
    final savedDefault = await AddressService.getDefaultAddress();

    if (savedDefault != null) {
      setState(() {
        _selectedAddress = savedDefault;
        _isInitializing = false;
      });
      return;
    }

    // First time user → create default from profile
    final user = UserSession.user;
    if (user != null) {
      final defaultAddress = Address(
        id: 'profile_default_${DateTime.now().millisecondsSinceEpoch}',
        fullName: user['full_name'] ?? 'User',
        phone: user['phone'] ?? '',
        houseDetails: user['address'] ?? '',
        village: user['village'] ?? '',
        taluka: user['taluka'] ?? '',
        district: user['district'] ?? '',
        state: user['state'] ?? '',
        pincode: user['pincode'] ?? '',
        isDefault: true,
      );

      final added = await AddressService.addAddress(defaultAddress);
      if (added) {
        setState(() {
          _selectedAddress = defaultAddress;
          _isInitializing = false;
        });
      }
    } else {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _openAddressManager() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageAddressesScreen()),
    );

    if (result is Address) {
      setState(() => _selectedAddress = result);
    }
  }

  String get _fullDeliveryAddress {
    if (_selectedAddress == null) return "No address selected";
    return [
      _selectedAddress!.houseDetails,
      _selectedAddress!.village,
      _selectedAddress!.taluka,
      _selectedAddress!.district,
      _selectedAddress!.state,
      _selectedAddress!.pincode,
    ].where((s) => s.isNotEmpty).join(', ');
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      final userId = UserSession.userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again')),
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
        address:
            "$_fullDeliveryAddress\n${_selectedAddress!.fullName} | ${_selectedAddress!.phone}",
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
            content: Text(
              _paymentMethod == PaymentMethod.cod
                  ? 'Order placed! Pay ₹${cart.totalCartValue.toStringAsFixed(0)} on delivery'
                  : 'Order placed successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Order failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  late Future<List<Offer>> _offersFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery & Payment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isInitializing) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.green));
          }

          final cart = snapshot.data ?? Cart(items: [], totalCartValue: 0.0);
          final totalAmount = cart.totalCartValue;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary

                // Offers Carousel
                SizedBox(
                  height: 150,
                  child: FutureBuilder<List<Offer>>(
                    future: _offersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.green));
                      }

                      final offers = snapshot.data ?? [];
                      final displayOffers = offers.isEmpty
                          ? [
                              Offer(
                                  title: "Flat 10% Off",
                                  message: "Use code KD1025",
                                  code: "KD1025",
                                  amount: "50"),
                              Offer(
                                  title: "Save ₹50",
                                  message: "On orders above ₹499",
                                  code: "SAVE50",
                                  amount: "50"),
                            ]
                          : offers;

                      final colorPairs = [
                        [Colors.pink, Colors.purple],
                        [Colors.orange, Colors.red],
                        [Colors.blue, Colors.teal],
                        [Colors.green, Colors.lightGreen],
                        [Colors.purple, Colors.indigo],
                      ];

                      return CarouselSlider(
                        options: CarouselOptions(
                          height: 150,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                          autoPlayInterval: const Duration(seconds: 4),
                        ),
                        items: displayOffers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final offer = entry.value;

                          final colors = colorPairs[index % colorPairs.length];

                          return Builder(builder: (context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      offer.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      offer.message,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    if (offer.code.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Code: ${offer.code}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                // Selected Address Card
                Card(
                  color: Colors.green.shade50,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.green, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery Address',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: _openAddressManager,
                              child: const Text('Change',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.green),
                        if (_selectedAddress != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(_selectedAddress!.fullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text(_selectedAddress!.phone),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_fullDeliveryAddress)),
                            ],
                          ),
                          if (_selectedAddress!.isDefault)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: const [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 20),
                                  SizedBox(width: 4),
                                  Text('Default Address',
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                        ] else
                          const Text('No address selected'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Payment Method
                const Text('Payment Method',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      RadioListTile<PaymentMethod>(
                        title: const Text('Cash on Delivery (COD)',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Pay when product is delivered'),
                        secondary:
                            const Icon(Icons.payments, color: Colors.green),
                        value: PaymentMethod.cod,
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      const Divider(height: 1),
                      RadioListTile<PaymentMethod>(
                        title: const Text('Online Payment',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        subtitle: const Text('UPI • Card • Netbanking'),
                        secondary:
                            const Icon(Icons.credit_card, color: Colors.blue),
                        value: PaymentMethod.online,
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // REPLACE THE OLD SUMMARY CARD WITH THIS ONE
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    FertilizerApiService().fetchFertilizers(),
                    widget.isBuyNow
                        ? CartService().getTempBuyNowCart()
                        : CartService().getCart(),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.hasError) {
                      return const Card(
                        elevation: 6,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Error loading cart summary'),
                        ),
                      );
                    }

                    final fertilizers = snapshot.data![0] as FertilizerResponse;
                    final cart = snapshot.data![1] as Cart;
                    final totalAmount = cart.totalCartValue;

                    final fertilizerMap = {
                      for (var f in fertilizers.results) f.productId: f
                    };

                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        // collapsedBackgroundColor: Colors.green.shade50,
                        backgroundColor: Colors.green.shade50,
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cart.items.length} item${cart.items.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text('Tap to view details',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 14)),
                              ],
                            ),
                            Text(
                              '₹${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              children: cart.items.map((item) {
                                final fertilizer =
                                    fertilizerMap[item.productId] ??
                                        Fertilizer(
                                          id: '',
                                          productName: 'Product Not Found',
                                          mrpPrice: '0',
                                          sellPrice: '0',
                                          productQuantity: '1',
                                          productUnit: 'Unit',
                                          productId: item.productId,
                                          soldQuantity: '0',
                                          availableQuantity: 0,
                                          status: '',
                                          images: [],
                                          isDeleted: true,
                                          createdAt: '',
                                          createdBy: '',
                                          category: '',
                                        );

                                final unitPrice =
                                    item.totalValue / item.quantity;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Optional Image
                                      // if (fertilizer.images.isNotEmpty)
                                      //   ClipRRect(
                                      //     borderRadius: BorderRadius.circular(8),
                                      //     child: Image.network(fertilizer.images[0].url, width: 50, height: 50, fit: BoxFit.cover),
                                      //   ),
                                      // const SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fertilizer.productName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.quantity} × ₹${unitPrice.toStringAsFixed(0)} • ${fertilizer.productUnit}',
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '₹${item.totalValue.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Payable',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Text('₹${totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _isLoading || _selectedAddress == null
                        ? null
                        : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _paymentMethod == PaymentMethod.cod
                                ? 'Place Order • Pay on Delivery'
                                : 'Pay ₹${totalAmount.toStringAsFixed(0)} Now',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
