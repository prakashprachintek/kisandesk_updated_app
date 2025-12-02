import 'package:flutter/material.dart';
import 'package:mainproject1/views/fertilizers/fertilizer_api_service.dart';
import '../services/user_session.dart';
import 'fertilizer_model.dart';
import 'cart_service.dart';
import 'cart_screen.dart';
import 'address_screen.dart';
import 'my_fertilizer_orders_screen.dart';

class FertilizerDetailsScreen extends StatefulWidget {
  final Fertilizer fertilizer;

  const FertilizerDetailsScreen({Key? key, required this.fertilizer})
      : super(key: key);

  @override
  State<FertilizerDetailsScreen> createState() =>
      _FertilizerDetailsScreenState();
}

class _FertilizerDetailsScreenState extends State<FertilizerDetailsScreen> {
  int _quantity = 1;
  late final int _maxAvailable = widget.fertilizer.availableQuantity;
  late Future<Cart> _cartFuture;
  late String _farmerId;

  @override
  void initState() {
    super.initState();
    _farmerId = UserSession.userId!;
    _cartFuture = CartService().getCart();
  }

  void _updateQuantity(int delta) {
    setState(() {
      final newQty = _quantity + delta;
      if (newQty >= 1 && newQty <= _maxAvailable) {
        _quantity = newQty;
      }
    });
  }

  // Add these in _FertilizerDetailsScreenState
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;
  bool _isSubmittingReview = false;

// Helper to calculate average rating
  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews
        .map((r) => double.tryParse(r.rating) ?? 0)
        .reduce((a, b) => a + b);
    return sum / reviews.length;
  }

// Star selector for writing review
  Widget _buildStarRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          iconSize: 48,
          padding: EdgeInsets.zero,
          icon: Icon(
            index < _selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 48,
          ),
          onPressed: () {
            setState(() => _selectedRating = index + 1);
          },
        );
      }),
    );
  }

// Review card (reusable)
  Widget _buildReviewCard(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    review.farmer.isNotEmpty
                        ? review.farmer[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(review.farmer,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                _buildRatingStars(double.tryParse(review.rating) ?? 0),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.comment,
                style: const TextStyle(fontSize: 14.5, height: 1.5)),
          ],
        ),
      ),
    );
  }

// Submit review API call
  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    setState(() => _isSubmittingReview = true);

    try {
      final response = await FertilizerApiService().addRating(
        fid: widget.fertilizer.id,
        userId: UserSession.userId!,
        rating: _selectedRating.toString(),
        comment: _reviewController.text.trim(),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your review has been submitted'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );

        _reviewController.clear();
        setState(() => _selectedRating = 5);

        // Optional: Refresh product to show new review
        // You can refetch the product if needed
      } else {
        throw Exception(response['message'] ?? 'Failed to submit');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmittingReview = false);
    }
  }

  // Add to existing cart
  Future<void> _addToCart() async {
    final item = CartItem(
      productId: widget.fertilizer.productId,
      quantity: _quantity,
      totalValue: widget.fertilizer.discountedPrice * _quantity,
    );

    await CartService().addToCart(item);
    setState(() => _cartFuture = CartService().getCart());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.fertilizer.productName} added to cart'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Buy Now → Creates temporary cart (safe for user)
  Future<void> _buyNow() async {
    final item = CartItem(
      productId: widget.fertilizer.productId,
      quantity: _quantity,
      totalValue: widget.fertilizer.discountedPrice * _quantity,
    );

    final tempCart = Cart(
      items: [item],
      totalCartValue: widget.fertilizer.discountedPrice * _quantity,
    );

    // Save to TEMP cart (main cart stays safe!)
    await CartService().setTempBuyNowCart(tempCart);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressScreen(isBuyNow: true),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int full = rating.floor();
    bool half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full)
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        if (i == full && half)
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fertilizer;
    final isOutOfStock = f.availableQuantity <= 0;
    final reviews = f.reviews ?? [];
    final details = f.productDetails;
    final description = f.description;
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          // Cart Icon with Live Badge
          FutureBuilder<Cart>(
            future: _cartFuture,
            builder: (context, snapshot) {
              final itemCount = snapshot.data?.items.length ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
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
                            borderRadius: BorderRadius.circular(10)),
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text('$itemCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                    ),
                ],
              );
            },
          ),

          // My Orders Icon
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Orders',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyFertilizerOrdersScreen(farmerId: _farmerId))),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 240,
              width: double.infinity,
              child: f.images.isEmpty
                  ? Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 80))
                  : PageView.builder(
                      itemCount: f.images.length,
                      itemBuilder: (context, index) => Image.network(
                        f.images[index].url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.error, size: 60),
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.productName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (f.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(f.category.capitalize(),
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 12),

                  // Price Row
                  Row(
                    children: [
                      if (f.mrp > f.sell)
                        Text('M.R.P ',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            )),
                      if (f.mrp > f.sell)
                        Text('₹${f.mrp.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough)),
                      if (f.mrp > f.sell) const SizedBox(width: 10),
                      Text('₹${f.discountedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (f.discountPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('${f.specialDiscount} OFF',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        isOutOfStock
                            ? Icons.error_outline
                            : Icons.inventory_2_outlined,
                        color: isOutOfStock ? Colors.red : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOutOfStock
                            ? 'Out of Stock'
                            : f.availableQuantity <= 20
                                ? 'Only ${f.availableQuantity} left!'
                                : 'In Stock • ${f.availableQuantity} available',
                        style: TextStyle(
                          fontSize: 14,
                          color: isOutOfStock
                              ? Colors.red
                              : (f.availableQuantity <= 20
                                  ? Colors.orange[700]
                                  : Colors.green),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('Pack Size: ${f.unit}',
                      style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  // Product Details
                  if (details != null && details.content.trim().isNotEmpty) ...[
                    const Text('Product Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(details.content,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                    const SizedBox(height: 20),
                    const Text('Usage',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(details.usage,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                    const SizedBox(height: 20),
                    
                  ],
                  // Description
                  if (description!.isNotEmpty) ...[
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(description,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // QUANTITY + BUTTONS
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? () => _updateQuantity(-1)
                                    : null),
                            SizedBox(
                              width: 40,
                              child: Text('$_quantity',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _quantity < f.availableQuantity
                                    ? () => _updateQuantity(1)
                                    : null),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 29, 108, 92),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Add to Cart',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : _buyNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Buy Now',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

// Reviews Section
                  if (reviews.isNotEmpty || true) ...[
                    const SizedBox(height: 28),

                    // ──────────────────────────────
                    // 1. CUSTOMER REVIEWS (No Container!)
                    // ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            'Customer Reviews',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Average Rating + Distribution Bars
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Big Rating Number
                              Column(
                                children: [
                                  Text(
                                    _calculateAverageRating(reviews)
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  _buildRatingStars(
                                      _calculateAverageRating(reviews)),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                child: Column(
                                  children: [5, 4, 3, 2, 1].map((star) {
                                    final count = reviews
                                        .where((r) =>
                                            (double.tryParse(r.rating) ?? 0)
                                                .floor() ==
                                            star)
                                        .length;
                                    final percentage = reviews.isEmpty
                                        ? 0.0
                                        : (count / reviews.length) * 100;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              width: 20,
                                              child: Text('$star',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600))),
                                          const Icon(Icons.star,
                                              size: 18, color: Colors.amber),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              backgroundColor: Colors.grey[300],
                                              color: Colors.amber,
                                              minHeight: 9,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                              width: 32,
                                              child: Text('$count',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600))),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Expandable Reviews
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            title: Text(
                              'Read all ${reviews.length} reviews',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 29, 108, 92),
                              ),
                            ),
                            trailing: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 28,
                                color: Color.fromARGB(255, 29, 108, 92)),
                            children: [
                              const Divider(
                                  height: 32,
                                  thickness: 1,
                                  color: Color(0xFFE0E0E0)),
                              ...reviews
                                  .map((review) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: _buildReviewCard(review),
                                      ))
                                  .toList(),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ──────────────────────────────
                    // 2. WRITE YOUR REVIEW (No Container!)
                    // ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.rate_review_outlined,
                                  color: Colors.green, size: 32),
                              SizedBox(width: 12),
                              Text(
                                'Write Your Review',
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(child: _buildStarRatingSelector()),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _reviewController,
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText:
                                  'Share your experience with this fertilizer...',
                              hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(18),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                      color: Colors.green, width: 2.5)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  _isSubmittingReview ? null : _submitReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 29, 108, 92),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 6,
                              ),
                              child: _isSubmittingReview
                                  ? const SizedBox(
                                      height: 26,
                                      width: 26,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 3))
                                  : const Text('Submit Review',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
  }
}
