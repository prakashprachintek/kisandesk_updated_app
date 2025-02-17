import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  // List to store favorited items
  final List<Map<String, String>> _favoriteItems = [];

  List<Map<String, String>> get favoriteItems => _favoriteItems;

  void toggleFavorite(Map<String, String> item) {
    if (_favoriteItems.contains(item)) {
      _favoriteItems.remove(item);
    } else {
      _favoriteItems.add(item);
    }
    notifyListeners(); // Notify listeners to update the UI
  }
}
