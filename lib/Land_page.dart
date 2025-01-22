import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'favoritePage.dart';
import 'landdetailspage.dart';

class LandPage extends StatefulWidget {
  @override
  _LandPageState createState() => _LandPageState();
}

class _LandPageState extends State<LandPage> {
  List<Map<String, dynamic>> landItems = []; // Dynamic list to store fetched land data
  List<Map<String, dynamic>> favoriteItems = []; // List to store favorite items

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLandPosts();
  }

  // API call to fetch land posts
  Future<void> fetchLandPosts() async {
    const String url = 'http://3.110.121.159/api/admin/getAll_market_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "land",
          "search": "",
          "currentPage": "1",
          "pageSize": "10",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results']; // Accessing the results key
        if (results != null) {
          setState(() {
            landItems =results.map<Map<String, dynamic>>((item) {
              final farmerDetails = (item['farmerDetails'] as List?)?.isNotEmpty == true
                ? item['farmerDetails'][0]
                : null;

            return {
              'name': item['post_name'] ?? 'Unknown Machinery',
              'price': item['price'] ?? 0,
              'description': item['description'] ?? 'No description available',
              'location': item['village'] ?? 'Unknown location',
              'image': item['image'] ?? ' assets/land1.jpg',
              'FarmerName': farmerDetails?['full_name'] ?? 'Unknown Farmer',
              'Phone': farmerDetails?['phone'] ?? 'N/A',
            };
            })
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('No results found in response: ${response.body}');
        }
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching land posts: $e');
    }
  }

  void toggleFavorite(Map<String, dynamic> landItem) {
    setState(() {
      if (favoriteItems.contains(landItem)) {
        favoriteItems.remove(landItem);
      } else {
        favoriteItems.add(landItem);
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
                hintText: "Search Land",
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : landItems.isEmpty
          ? Center(child: Text('No land posts found.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 2.5,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: landItems.length,
          itemBuilder: (context, index) {
            final landItem = landItems[index];
            final isFavorited = favoriteItems.contains(landItem);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => landdetailspage(
                      name: landItem['name'],
                      price: '₹${landItem['price']}',
                      imagePath: landItem['image'],
                      location: landItem['location'] ?? 'Unknown location', // Make sure location is not null
                      description: landItem['description'] ?? 'No description available', // Make sure description is not null
                      FarmerName: landItem['FarmerName'], // Pass full name
                      Phone: landItem['Phone'], // Pass phone
                      review: 'This is a sample review.',
                    ),
                  ),
                );
              },
              child: LandCard(
                name: landItem['name'],
                price: '₹${landItem['price']}',
                imagePath: landItem['image'],
                isFavorited: isFavorited,
                onFavoritePressed: () => toggleFavorite(landItem),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LandCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isFavorited;
  final VoidCallback onFavoritePressed;

  const LandCard({
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
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/land1.jpg',
                  fit: BoxFit.cover,
                ),
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
