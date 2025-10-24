import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'fertilizer_model.dart';

class CartService {
  static const String _cartKey = 'cart';

  Future<void> addToCart(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCart();
    final existingItemIndex =
        cart.items.indexWhere((i) => i.productId == item.productId);

    if (existingItemIndex != -1) {
      // Update existing item
      final existingItem = cart.items[existingItemIndex];
      final updatedItem = CartItem(
        productId: existingItem.productId,
        quantity: existingItem.quantity + item.quantity,
        totalValue: existingItem.totalValue + item.totalValue,
      );
      cart.items[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      cart.items.add(item);
    }

    // Update total cart value
    final newTotal = cart.items.fold<double>(
        0, (sum, item) => sum + item.totalValue);
    final updatedCart = Cart(items: cart.items, totalCartValue: newTotal);

    // Save to shared_preferences
    await prefs.setString(_cartKey, jsonEncode(updatedCart.toJson()));
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCart();
    final itemIndex = cart.items.indexWhere((i) => i.productId == productId);

    if (itemIndex != -1 && newQuantity > 0) {
      final item = cart.items[itemIndex];
      final unitPrice = item.totalValue / item.quantity;
      final updatedItem = CartItem(
        productId: item.productId,
        quantity: newQuantity,
        totalValue: unitPrice * newQuantity,
      );
      cart.items[itemIndex] = updatedItem;

      // Update total cart value
      final newTotal = cart.items.fold<double>(
          0, (sum, item) => sum + item.totalValue);
      final updatedCart = Cart(items: cart.items, totalCartValue: newTotal);

      await prefs.setString(_cartKey, jsonEncode(updatedCart.toJson()));
    }
  }

  Future<void> removeFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCart();
    cart.items.removeWhere((item) => item.productId == productId);

    // Update total cart value
    final newTotal = cart.items.fold<double>(
        0, (sum, item) => sum + item.totalValue);
    final updatedCart = Cart(items: cart.items, totalCartValue: newTotal);

    await prefs.setString(_cartKey, jsonEncode(updatedCart.toJson()));
  }

  Future<Cart> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) {
      return Cart(items: [], totalCartValue: 0.0);
    }
    return Cart.fromJson(jsonDecode(cartJson));
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}