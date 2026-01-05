import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mainproject1/views/fertilizers/fertilizer_requests_screen.dart';
import '../services/user_session.dart';
import 'fertilizer_model.dart';
import 'fertilizer_api_service.dart';
import 'fertilizer_details_screen.dart';
import 'my_fertilizer_orders_screen.dart';
import 'cart_screen.dart';
import 'cart_service.dart';

class FertilizerListScreen extends StatefulWidget {
  const FertilizerListScreen({Key? key}) : super(key: key);

  @override
  _FertilizerListScreenState createState() => _FertilizerListScreenState();
}

class _FertilizerListScreenState extends State<FertilizerListScreen> {
  late Future<FertilizerResponse> _fertilizerFuture;
  late Future<Cart> _cartFuture;
  List<Fertilizer> _fertilizers = [];
  List<Fertilizer> _filteredFertilizers = [];
  String _searchQuery = '';
  String _sortOrder = 'none';
  late String _farmerId;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();


  String _selectedCategory = "";

  Map<String, int> _cartQuantities = {};

  @override
  void initState() {
    super.initState();
    _farmerId = UserSession.userId!;
    _fertilizerFuture = FertilizerApiService().fetchFertilizers();
    _cartFuture = CartService().getCart()..then((_) => _loadCartQuantities());
  }

  void _applyCategoryFilter() {
    if (_selectedCategory.isEmpty) {
      _filteredFertilizers = List.from(_fertilizers);
    } else {
      _filteredFertilizers = _fertilizers.where((f) {
        return f.category.toLowerCase() == _selectedCategory.toLowerCase();
      }).toList();
    }

    _applySort();
    setState(() {});
  }

  Widget _buildCategoryChip(String label, String value) {
    bool selected = _selectedCategory == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color.fromARGB(255, 29, 108, 92),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) {
        setState(() {
          _selectedCategory = value;
        });
        _applyCategoryFilter();
      },
    );
  }

  void _filterFertilizers(String query) {
    setState(() {
      _searchQuery = query;

      // Start from full list
      List<Fertilizer> temp = List.from(_fertilizers);

      // Apply search
      if (query.isNotEmpty) {
        temp = temp
            .where((f) =>
                f.productName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      // Apply category filter
      if (_selectedCategory.isNotEmpty) {
        temp = temp
            .where((f) =>
                f.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();
      }

      // Apply sorting
      if (_sortOrder == 'ascending') {
        temp.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
      } else if (_sortOrder == 'descending') {
        temp.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
      }

      _filteredFertilizers = temp;
    });
  }

  void _applySort() {
    if (_sortOrder == 'ascending') {
      _filteredFertilizers
          .sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
    } else if (_sortOrder == 'descending') {
      _filteredFertilizers
          .sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
    }
  }

  void _openSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('price_low_to_high').tr(),
              trailing: _sortOrder == 'ascending'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _sortOrder = 'ascending';
                  _applySort();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('price_high_to_low').tr(),
              trailing: _sortOrder == 'descending'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _sortOrder = 'descending';
                  _applySort();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear_Sorting').tr(),
              trailing: _sortOrder == 'none'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _sortOrder = 'none';
                  _filteredFertilizers = List.from(_fertilizers);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCartQuantities() async {
    final cart = await CartService().getCart();
    final Map<String, int> quantities = {};

    for (var item in cart.items) {
      quantities[item.productId] = item.quantity;
    }

    if (mounted) {
      setState(() {
        _cartQuantities = quantities;
      });
    }
  }

  Future<void> _refreshCartState() async {
    setState(() {
      _cartFuture = CartService().getCart();
    });
    await _loadCartQuantities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizers',
            style: TextStyle(fontWeight: FontWeight.bold)).tr(),
        elevation: 0,
        actions: [
          FutureBuilder<Cart>(
            future: _cartFuture,
            builder: (context, snapshot) {
              int itemCount =
                  snapshot.hasData ? snapshot.data!.items.length : 0;

              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    tooltip: 'Cart'.tr(),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'My_Orders'.tr(),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      MyFertilizerOrdersScreen(farmerId: _farmerId)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delivery_dining),
            tooltip: 'My_Orders'.tr(),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      FertilizerRequestsScreen()),
            ),

          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // SEARCH + SORT ROW
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: _filterFertilizers,
                      decoration: InputDecoration(
                        hintText: 'Search_fertilizers...'.tr(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                  _filterFertilizers(''); // Clear search
                                  _searchFocus.unfocus();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 29, 108, 92),
                              width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 80, 70),
                              width: 2.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Sort'.tr(),
                    onPressed: _openSortBottomSheet,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip("All".tr(), ""),
                    const SizedBox(width: 10),
                    _buildCategoryChip("Herbicides".tr(), "herbicide"),
                    const SizedBox(width: 10),
                    _buildCategoryChip("Insecticides".tr(), "insecticide"),
                    const SizedBox(width: 10),
                    _buildCategoryChip("Rodenticides".tr(), "rodenticide"),
                    const SizedBox(width: 10),
                    _buildCategoryChip("Acaricides".tr(), "acaricide")
                  ],
                ),
              ),
            ),

            // PRODUCT LIST
            Expanded(
              child: FutureBuilder<FertilizerResponse>(
                future: _fertilizerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.results.isEmpty) {
                    return const Center(child: Text('No fertilizers found'));
                  }

                  _fertilizers = snapshot.data!.results;
                  // REMOVE THIS ENTIRE BLOCK FROM FutureBuilder
// _filteredFertilizers = _filteredFertilizers.isEmpty
//     ? List.from(_fertilizers)
//     : _filteredFertilizers;

// REPLACE WITH THIS:
                  if (_searchQuery.isEmpty &&
                      _selectedCategory.isEmpty &&
                      _sortOrder == 'none') {
                    _filteredFertilizers = List.from(_fertilizers);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFertilizers.length,
                    itemBuilder: (context, index) {
                      final f = _filteredFertilizers[index];
                      final int currentQty = _cartQuantities[f.productId] ?? 0;
                      final bool isInCart = currentQty > 0;
                      final bool isOutOfStock = f.availableQuantity <= 0;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  FertilizerDetailsScreen(fertilizer: f)),
                        ),
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color.fromARGB(215, 223, 241, 223),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(12)),
                                  child: SizedBox(
                                    width: 120,
                                    height: 200,
                                    child: Image.network(
                                      f.images.isNotEmpty
                                          ? f.images[0].url
                                          : '',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.image_not_supported,
                                          size: 40),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          f.productName,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${f.discountedPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 10),
                                            if (f.specialDiscount != '0%')
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${f.specialDiscount} OFF',
                                                  style: const TextStyle(
                                                      color: Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text('M.R.P',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey)),
                                            const SizedBox(width: 8),
                                            Text(
                                              '₹${f.mrpPrice}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              f.unit,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                            const Spacer(),
                                            if (f.availableStock <= 20)
                                              Text(
                                                f.availableStock <= 0
                                                    ? 'Out_of_stock'.tr()
                                                    : 'Only ${f.availableStock} left',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: f.availableStock <= 0
                                                      ? Colors.red
                                                      : Colors.orange[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

// MAIN BUTTON LOGIC
                                        if (isOutOfStock)
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: null,
                                              child: Text('Out_of_stock'.tr(),
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ),
                                          )
                                        else if (!isInCart)
                                          // NOT IN CART → Show "Add" + "Buy Now" side by side
                                          Row(
                                            children: [
                                              // ADD TO CART BUTTON
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    try {
                                                      final item = CartItem(
                                                        productId: f.productId,
                                                        quantity: 1,
                                                        totalValue:
                                                            f.discountedPrice,
                                                      );
                                                      await CartService()
                                                          .addToCart(item);
                                                      await _refreshCartState();

                                                      if (mounted) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Added to cart ✓'),
                                                            backgroundColor:
                                                                Colors.green,
                                                            duration: Duration(
                                                                seconds: 1),
                                                          ),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  'Failed: $e'),
                                                              backgroundColor:
                                                                  Colors.red),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  // icon: const Icon(Icons.add_shopping_cart, size: 20),
                                                  label: Text(
                                                      "Add_to_Cart".tr(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 29, 108, 92),
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              // BUY NOW BUTTON (Orange, with lightning icon)
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              FertilizerDetailsScreen(
                                                                  fertilizer:
                                                                      f)),
                                                    );
                                                  },
                                                  // icon: const Icon(Icons.flash_on, size: 22), // Lightning = fast buy
                                                  label: Text("Buy_Now".tr(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orange.shade700,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    elevation: 3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          // ALREADY IN CART → Full-width quantity control (unchanged, perfect)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                      255, 29, 108, 92)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 29, 108, 92)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      color: Colors.red,
                                                      size: 28),
                                                  onPressed: () async {
                                                    final newQty =
                                                        currentQty - 1;
                                                    if (newQty <= 0) {
                                                      await CartService()
                                                          .removeFromCart(
                                                              f.productId);
                                                    } else {
                                                      await CartService()
                                                          .updateQuantity(
                                                              f.productId,
                                                              newQty);
                                                    }
                                                    await _refreshCartState();
                                                  },
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 28),
                                                  child: Text('$currentQty',
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle_outline,
                                                      color: Colors.green,
                                                      size: 28),
                                                  onPressed: currentQty <
                                                          f.availableQuantity
                                                      ? () async {
                                                          await CartService()
                                                              .updateQuantity(
                                                                  f.productId,
                                                                  currentQty +
                                                                      1);
                                                          await _refreshCartState();
                                                        }
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
