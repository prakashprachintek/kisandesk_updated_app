import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'machinerydetailspage.dart';
import 'favoritePage.dart';

class MachineryPage extends StatefulWidget {
  @override
  _MachineryPageState createState() => _MachineryPageState();
}

class _MachineryPageState extends State<MachineryPage> {
  List<Map<String, dynamic>> machineryItems = []; // List to store machinery items
  List<Map<String, dynamic>> favoriteItems = []; // List to store favorite machinery items
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachineryPosts();
  }

  // Fetch machinery posts from API
  Future<void> fetchMachineryPosts() async {
    const String url = 'http://3.110.121.159/api/admin/getAll_market_post'; // Replace with your API endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "machinery",  // Adjust the category for machinery
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
            machineryItems = results.map<Map<String, dynamic>>((item) {
              final farmerDetails = (item['farmerDetails'] as List?)?.isNotEmpty == true
                  ? item['farmerDetails'][0]
                  : null;

              return {
                'name': item['post_name'] ?? 'Unknown Machinery',
                'price': item['price'] ?? 0,
                'description': item['description'] ?? 'No description available',
                'location': item['village'] ?? 'Unknown location',
                'image': item['image'] ?? 'assets/machinery1.webp',
                'FarmerName': farmerDetails?['full_name'] ?? 'Unknown Farmer',
                'Phone': farmerDetails?['phone'] ?? 'N/A',
              };
            }).toList();
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
      print('Error fetching machinery posts: $e');
    }
  }

  void toggleFavorite(Map<String, dynamic> machineryItem) {
    setState(() {
      if (favoriteItems.contains(machineryItem)) {
        favoriteItems.remove(machineryItem);
      } else {
        favoriteItems.add(machineryItem);
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
                hintText: "Search Machinery",
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
          : machineryItems.isEmpty
          ? Center(child: Text('No machinery posts found.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 2.5,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: machineryItems.length,
          itemBuilder: (context, index) {
            final machineryItem = machineryItems[index];
            final isFavorited = favoriteItems.contains(machineryItem);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Machinerydetailspage(
                      name: machineryItem['name'],
                      price: '₹${machineryItem['price']}',
                      imagePath: machineryItem['image'],
                      location: machineryItem['location'] ?? 'Unknown location', // Make sure location is not null
                      description: machineryItem['description'] ?? 'No description available', // Make sure description is not null
                      FarmerName: machineryItem['FarmerName'], // Pass full name
                      Phone: machineryItem['Phone'], // Pass phone
                      review: 'This is a sample review.',
                    ),
                  ),
                );
              },
              child: MachineryCard(
                name: machineryItem['name'],
                price: '₹${machineryItem['price']}',
                imagePath: machineryItem['image'],
                isFavorited: isFavorited,
                onFavoritePressed: () => toggleFavorite(machineryItem),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MachineryCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isFavorited;
  final VoidCallback onFavoritePressed;

  const MachineryCard({
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
                  'assets/machinery1.webp',
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
