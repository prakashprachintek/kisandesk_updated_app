import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteItems;

  const FavoritePage({required this.favoriteItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Color(0xFF00AD83),
      ),
      body: favoriteItems.isEmpty
          ? Center(child: Text('No favorite items.'))
          : ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          final item = favoriteItems[index];
          return ListTile(
            leading: Image.network(item['image'], width: 50, height: 50),
            title: Text(item['name']),
            subtitle: Text('₹${item['price']}'),
            trailing: IconButton(
              icon: Icon(Icons.favorite, color: Color(0xFF00AD83)),
              onPressed: () {
                // Optionally, remove item from favorites when tapped again
              },
            ),
          );
        },
      ),
    );
  }
}