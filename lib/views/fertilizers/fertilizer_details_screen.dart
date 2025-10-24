import 'package:flutter/material.dart';
import 'fertilizer_model.dart';
import 'cart_service.dart';
import 'cart_screen.dart';

class FertilizerDetailsScreen extends StatefulWidget {
  final Fertilizer fertilizer;

  const FertilizerDetailsScreen({Key? key, required this.fertilizer}) : super(key: key);

  @override
  _FertilizerDetailsScreenState createState() => _FertilizerDetailsScreenState();
}

class _FertilizerDetailsScreenState extends State<FertilizerDetailsScreen> {
  int _quantity = 1;
  static const int _maxQuantity = 8;

  // Calculate discounted price
  double _calculateDiscountedPrice(String amount, String discount) {
    double originalPrice = double.parse(amount);
    double discountPercentage = double.parse(discount.replaceAll('%', '')) / 100;
    return originalPrice * (1 - discountPercentage);
  }

  @override
  Widget build(BuildContext context) {
    final discountedPrice = _calculateDiscountedPrice(widget.fertilizer.amount, widget.fertilizer.discount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizers', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: PageView.builder(
                itemCount: widget.fertilizer.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.fertilizer.images[index].url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fertilizer.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${widget.fertilizer.amount}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${discountedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.fertilizer.discount} discount',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quantity: ${widget.fertilizer.quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Product ID: ${widget.fertilizer.productId}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _quantity < _maxQuantity
                                ? () {
                                    setState(() {
                                      _quantity++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_quantity <= 0 || _quantity > _maxQuantity) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a quantity between 1 and 8')),
                              );
                              return;
                            }
                            final cartItem = CartItem(
                              productId: widget.fertilizer.productId,
                              quantity: _quantity,
                              totalValue: discountedPrice * _quantity,
                            );
                            await CartService().addToCart(cartItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${widget.fertilizer.productName} added to cart')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 29, 108, 92),
                            minimumSize: const Size(0, 50),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 29, 108, 92),
                            minimumSize: const Size(0, 50),
                          ),
                          child: const Text(
                            'Go to Cart',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}