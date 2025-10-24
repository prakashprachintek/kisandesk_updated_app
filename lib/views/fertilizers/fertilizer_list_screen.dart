import 'package:flutter/material.dart';
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
  String _sortOrder = 'none'; // none, ascending, descending
  late String _farmerId; // Dynamic farmerId from UserSession

  @override
  void initState() {
    super.initState();
    _farmerId = UserSession.userId!; // Dynamic farmerId from UserSession
    _fertilizerFuture = FertilizerApiService().fetchFertilizers();
    _cartFuture = CartService().getCart();
  }

  void _filterFertilizers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFertilizers = List.from(_fertilizers);
      } else {
        _filteredFertilizers = _fertilizers
            .where((fertilizer) => fertilizer.productName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
      _applySort();
    });
  }

  void _applySort() {
    if (_sortOrder == 'ascending') {
      _filteredFertilizers.sort((a, b) =>
          double.parse(a.amount).compareTo(double.parse(b.amount)));
    } else if (_sortOrder == 'descending') {
      _filteredFertilizers.sort((a, b) =>
          double.parse(b.amount).compareTo(double.parse(a.amount)));
    }
  }

  void _toggleSortOrder() {
    setState(() {
      if (_sortOrder == 'none') {
        _sortOrder = 'ascending';
      } else if (_sortOrder == 'ascending') {
        _sortOrder = 'descending';
      } else {
        _sortOrder = 'none';
        _filteredFertilizers = List.from(_fertilizers);
      }
      _applySort();
    });
  }

  // Calculate discounted price
  double _calculateDiscountedPrice(String amount, String discount) {
    double originalPrice = double.parse(amount);
    double discountPercentage = double.parse(discount.replaceAll('%', '')) / 100;
    return originalPrice * (1 - discountPercentage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizers', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          FutureBuilder<Cart>(
            future: _cartFuture,
            builder: (context, snapshot) {
              int itemCount = snapshot.hasData ? snapshot.data!.items.length : 0;
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    tooltip: 'Cart',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
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
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyFertilizerOrdersScreen(farmerId: _farmerId),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search fertilizers...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 29, 108, 92), // Border when unfocused
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 29, 108, 92), // Border when unfocused
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 20, 80, 70), // Darker shade when focused
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: _filterFertilizers,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: Icon(
                      _sortOrder == 'ascending'
                          ? Icons.arrow_upward
                          : _sortOrder == 'descending'
                              ? Icons.arrow_downward
                              : Icons.sort,
                    ),
                    onPressed: _toggleSortOrder,
                    tooltip: 'Sort by price',
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<FertilizerResponse>(
                future: _fertilizerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
                    return const Center(child: Text('No fertilizers found'));
                  }

                  _fertilizers = snapshot.data!.results;
                  _filteredFertilizers =
                      _searchQuery.isEmpty && _sortOrder == 'none'
                          ? List.from(_fertilizers)
                          : _filteredFertilizers.isEmpty
                              ? List.from(_fertilizers)
                              : _filteredFertilizers;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredFertilizers.length,
                    itemBuilder: (context, index) {
                      final fertilizer = _filteredFertilizers[index];
                      final discountedPrice =
                          _calculateDiscountedPrice(fertilizer.amount, fertilizer.discount);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FertilizerDetailsScreen(fertilizer: fertilizer),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color.fromARGB(215, 223, 241, 223), // Light green
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.horizontal(left: Radius.circular(12)),
                                  child: SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Image.network(
                                      fertilizer.images.isNotEmpty
                                          ? fertilizer.images[0].url
                                          : '',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.error),
                                    ),
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
                                        Row(
                                          children: [
                                            Text(
                                              '₹${fertilizer.amount}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '₹${discountedPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${fertilizer.discount} discount',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        Text(
                                          fertilizer.quantity,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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