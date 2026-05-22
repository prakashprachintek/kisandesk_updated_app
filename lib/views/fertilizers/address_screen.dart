import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mainproject1/views/fertilizers/fertilizer_offer_model.dart';
import 'package:mainproject1/views/fertilizers/my_fertilizer_orders_screen.dart';
import 'package:mainproject1/views/home/HomePage.dart';
import '../services/user_session.dart';
import 'address_service.dart';
import 'address_model.dart';
import 'manage_address_screen.dart';
import 'cart_service.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_model.dart';
import '../services/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_screen.dart';
import 'fertilizer_details_screen.dart';

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
  double _discountPercent = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDiscount();
    _cartFuture = widget.isBuyNow
        ? CartService().getTempBuyNowCart()
        : CartService().getCart();
    _initializeDefaultAddress();
    _offersFuture = FertilizerApiService().fetchFertilizerOffers();
  }

  Future<void> _loadDiscount() async {
    final prefs = await SharedPreferences.getInstance();
    final discount = prefs.getDouble('fertilizer_discount') ?? 0;

    setState(() {
      _discountPercent = discount;
    });
  }

  void _handleEditClick(BuildContext context, String productId) {
    if (widget.isBuyNow) {
      // 👉 Coming from Product Details (Buy Now)
      Navigator.pop(context);
    } else {
      // 👉 Coming from Cart
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CartScreen(),
        ),
      );
    }
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
    if (_selectedAddress == null) return "No_address_selected".tr();
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
        SnackBar(content: Text('Please_select_a_delivery_address').tr()),
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
          SnackBar(content: Text('Your_cart_is_empty').tr()),
        );
        return;
      }

      final userId = UserSession.userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please_login_again').tr()),
        );
        return;
      }
// ────────────────────────────────────────────────
      //          Add these print statements here
      // ────────────────────────────────────────────────

      print('╔═══════════════════════════════════════════════');
      print('║          PLACE ORDER BUTTON PRESSED           ');
      print('╠═══════════════════════════════════════════════');
      print('║ User ID       : $userId');
      print(
          '║ Payment       : ${_paymentMethod == PaymentMethod.cod ? "COD" : "Online"}');
      print('║ Total Amount  : ₹${cart.totalCartValue.toStringAsFixed(0)}');
      print('║ Items count   : ${cart.items.length}');

      // Print each product being sent
      print('║ Products sending:');
      for (var item in cart.items) {
        print('║   • ${item.productId.padRight(12)}  qty: ${item.quantity}');
      }

      // The exact address string that will be sent
      final addressString =
          "$_fullDeliveryAddress\n${_selectedAddress!.fullName} | ${_selectedAddress!.phone}";
      print('║ Address sending:');
      print('║   $addressString');

      // The exact payload that goes to the API
      final payload = {
        'userId': userId,
        'products': cart.items
            .map((item) => {
                  'id': item.productId,
                  'quantity': item.quantity.toString(),
                })
            .toList(),
        'amount': cart.totalCartValue.toStringAsFixed(0),
        'address': addressString,
      };

      print('║ ──────────────────────────────────────────────');
      print('║ Payload that will be sent to bookFertilizerOrder:');
      print(payload); // ← this is the most important one
      print('╚═══════════════════════════════════════════════');

      // ────────────────────────────────────────────────

      final discountAmount =
    (cart.totalCartValue * _discountPercent) / 100;

final finalAmount = cart.totalCartValue - discountAmount;

      final response = await FertilizerApiService().bookFertilizerOrder(
        userId: userId,
        products: cart.items
            .map((item) => {
                  'id': item.productId,
                  'quantity': item.quantity.toString(),
                })
            .toList(),
            amount: finalAmount.toStringAsFixed(0),
        //amount: cart.totalCartValue.toStringAsFixed(0),
        address: addressString,
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

        final userId = UserSession.userId;

        if (userId == null || userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please_login_again").tr()),
          );
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MyFertilizerOrdersScreen(
              farmerId: userId,
            ),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Order failed')),
        );
      }
    } catch (e) {
      print('Place Order Exception: $e');
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
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery_&_Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ).tr(),
        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // TOP SCROLL AREA
          Expanded(
            child: FutureBuilder<Cart>(
              future: _cartFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isInitializing) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                final cart =
                    snapshot.data ?? Cart(items: [], totalCartValue: 0.0);
                //final totalAmount = cart.totalCartValue;
                final totalAmount = cart.totalCartValue;

final discountAmount =
    (totalAmount * _discountPercent) / 100;

final finalAmount = totalAmount - discountAmount;

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(w * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // -------------------------
                      // OFFERS CAROUSEL (your code as-is)
                      // -------------------------
                      SizedBox(
                        height: h * 0.13,
                        child: FutureBuilder<List<Offer>>(
                          future: _offersFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.green),
                              );
                            }

                            final offers = snapshot.data ?? [];

                            final displayOffers = offers.isEmpty
                                ? [
                                    Offer(
                                      title: "Exclusive Offer",
                                      message: "Get additional savings",
                                      code: "",
                                      amount: "0",
                                    ),
                                    Offer(
                                      title: "Best Price Guaranteed",
                                      message: "Unbeatable prices",
                                      code: "",
                                      amount: "0",
                                    ),
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
                                height: h * 0.13,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 1.0,
                                autoPlayInterval: const Duration(seconds: 4),
                              ),
                              items: displayOffers.asMap().entries.map((entry) {
                                final index = entry.key;
                                final offer = entry.value;
                                final colors =
                                    colorPairs[index % colorPairs.length];

                                return Container(
                                  width: w,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: w * 0.02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: colors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(w * 0.04),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            offer.title,
                                            style: TextStyle(
                                              fontSize: h * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: h * 0.005),
                                          Text(
                                            offer.message,
                                            style: TextStyle(
                                              fontSize: h * 0.016,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                      // -------------------------
                      // ADDRESS CARD (same code, just spacing updated)
                      // -------------------------
                      Card(
                        color: Colors.green.shade50,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.green, width: 2),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              w * 0.04, w * 0.03, w * 0.04, w * 0.04),
                          // padding: EdgeInsets.all(w * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery Address',
                                    style: TextStyle(
                                      fontSize: h * 0.024,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _openAddressManager,
                                    child: Text(
                                      'Change',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: h * 0.02,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Transform.translate(
                                offset: Offset(0,
                                    -7), // move divider UP (increase/decrease as needed)
                                child: const Divider(color: Colors.green),
                              ),
                              if (_selectedAddress != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.green),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _selectedAddress!.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.phone,
                                        size: 16, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedAddress!.phone,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: h * 0.01),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.green),
                                    SizedBox(width: w * 0.02),
                                    Expanded(
                                      child: Text(
                                        _fullDeliveryAddress,
                                        style: TextStyle(fontSize: h * 0.018),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.03),

                      // Payment Method
                      Text('Payment_Method',
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold)).tr(),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            RadioListTile<PaymentMethod>(
                              title: Text('Cash_on_Delivery_(COD)',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)).tr(),
                              subtitle:
                                  Text('Pay_when_product_is_delivered').tr(),
                              secondary: const Icon(Icons.payments,
                                  color: Colors.green),
                              value: PaymentMethod.cod,
                              groupValue: _paymentMethod,
                              onChanged: (v) =>
                                  setState(() => _paymentMethod = v!),
                            ),
                            /*
                            const Divider(height: 1),
                            RadioListTile<PaymentMethod>(
                              title: const Text('Online Payment',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              subtitle: const Text('UPI • Card • Netbanking'),
                              secondary: const Icon(Icons.credit_card,
                                  color: Colors.blue),
                              value: PaymentMethod.online,
                              groupValue: _paymentMethod,
                              onChanged: (v) =>
                                  setState(() => _paymentMethod = v!),
                            ),*/
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Padding(
                                padding: EdgeInsets.all(20),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.hasError) {
                            return Card(
                              elevation: 6,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('Error_loading_cart_summary').tr(),
                              ),
                            );
                          }

                          final fertilizers =
                              snapshot.data![0] as FertilizerResponse;
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
                              onExpansionChanged: (expanded) {
                                if (expanded) {
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeOut,
                                    );
                                  });
                                }
                              },
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${cart.items.length} item${cart.items.length == 1 ? '' : 's'}',
                                        style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('Tap_to_details',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 14)).tr(),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  child: Column(
                                    children: cart.items.map((item) {
                                      final fertilizer =
                                          fertilizerMap[item.productId] ??
                                              Fertilizer(
                                                id: '',
                                                productName:
                                                    'Product Not Found',
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
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
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                            Column(
                                              children: [
                                                Text(
                                                  '₹${item.totalValue.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                GestureDetector(
                                                  onTap: () {
                                                    _handleEditClick(context,
                                                        item.productId);
                                                  },
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            )
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total Payable',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      '₹${totalAmount.toStringAsFixed(0)}',
      style: const TextStyle(
        fontSize: 20,
        decoration: TextDecoration.lineThrough,
        color: Colors.grey,
      ),
    ),
    if (_discountPercent > 0)
      Text(
        '-${_discountPercent.toStringAsFixed(0)}%',
        style: const TextStyle(color: Colors.green),
      ),
    Text(
      '₹${finalAmount.toStringAsFixed(0)}',
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
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),

          // -------------------------
          // FIXED BOTTOM BUTTON — ALWAYS VISIBLE
          // -------------------------
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.04),
              child: SizedBox(
                height: h * 0.07,
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedAddress == null
                      ? null
                      : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _paymentMethod == PaymentMethod.cod
                              ? 'Place Order • Pay on Delivery'
                              : 'Pay Now',
                          style: TextStyle(
                            fontSize: h * 0.022,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
