import 'package:flutter/material.dart';
import 'Pesticidesdetailspage.dart';
import 'favoritePage.dart';

class PesticidesPage extends StatefulWidget {
  @override
  _PesticidesPageState createState() => _PesticidesPageState();
}

class _PesticidesPageState extends State<PesticidesPage> {
  // Sample data for pesticides items
  final List<Map<String, String>> pesticidesItems = [
    {
      'name': 'Pesticides 1',
      'price': '₹10,000',
      'image': 'assets/pesticides1.webp',
    },
    {
      'name': 'Pesticides 2',
      'price': '₹15,000',
      'image': 'assets/pesticide2.webp',
    },
    {
      'name': 'Pesticides 3',
      'price': '₹12,000',
      'image': 'assets/pesticides1.webp',
    },
    {
      'name': 'Pesticides 4',
      'price': '₹20,000',
      'image': 'assets/pesticide2.webp',
    },
    {
      'name': 'Pesticides 5',
      'price': '₹10,000',
      'image': 'assets/pesticides1.webp',
    },
    {
      'name': 'Pesticides 6',
      'price': '₹15,000',
      'image': 'assets/pesticide2.webp',
    },
    {
      'name': 'Pesticides 7',
      'price': '₹10,000',
      'image': 'assets/pesticides1.webp',
    },
    {
      'name': 'Pesticides 8',
      'price': '₹15,000',
      'image': 'assets/pesticide2.webp',
    },
    // Add more pesticides items as needed
  ];

  // List to store favorited pesticides
  List<Map<String, String>> favoriteItems = [];

  // Function to toggle favorite status
  void toggleFavorite(Map<String, String> pesticideItem) {
    setState(() {
      if (favoriteItems.contains(pesticideItem)) {
        favoriteItems.remove(pesticideItem);
      } else {
        favoriteItems.add(pesticideItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Pesticides",
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              // Navigate to the FavoritePage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritePage(favoriteItems: favoriteItems),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two items per row
            childAspectRatio: 2 / 2.5, // Adjust the aspect ratio to make cards smaller
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: pesticidesItems.length,
          itemBuilder: (context, index) {
            final pesticideItem = pesticidesItems[index];
            final isFavorited = favoriteItems.contains(pesticideItem);

            return GestureDetector(
              onTap: () {
                // Navigate to PesticidesDetailPage with the selected item's data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Pesticidesdetailspage(
                      name: pesticideItem['name']!,
                      price: pesticideItem['price']!,
                      imagePath: pesticideItem['image']!,
                      location: 'Sample Location', // Provide appropriate location data here
                      description: 'Sample description for this pesticide.', // Provide a description
                      review: 'This is a sample review.', // Provide the review text here
                    ),
                  ),
                );
              },
              child: PesticidesCard(
                name: pesticideItem['name']!,
                price: pesticideItem['price']!,
                imagePath: pesticideItem['image']!,
                isFavorited: isFavorited,
                onFavoritePressed: () => toggleFavorite(pesticideItem),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PesticidesCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isFavorited;
  final VoidCallback onFavoritePressed;

  const PesticidesCard({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.isFavorited,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      price,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Color(0xFF00AD83),
                  ),
                  onPressed: onFavoritePressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
