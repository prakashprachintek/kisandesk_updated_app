import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'CattleDetailsPage.dart';

class CattlePage extends StatefulWidget {
  @override
  _CattlePageState createState() => _CattlePageState();
}

class _CattlePageState extends State<CattlePage> {
  List<Map<String, dynamic>> cattleItems = [];
  List<Map<String, dynamic>> favoriteItems = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  String selectedFilter = '';

  @override
  void initState() {
    super.initState();
    fetchCattlePosts();
  }

  Future<void> fetchCattlePosts() async {
    const String url = 'http://3.110.121.159/api/admin/getAll_market_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "cattle",
          "search": "",
          "currentPage": "1",
          "pageSize": "10",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data');  // Debug: Check the full API response
        final results = data['results']; // Accessing the results key
        if (results != null) {
          setState(() {
            cattleItems = results.map<Map<String, dynamic>>((item) {
              final farmerDetails = item['farmerDetails']?.isNotEmpty == true
                  ? item['farmerDetails'][0]
                  : null;
              // Extract the image URL (post_url) from the API response
            //  String postUrl = item['post_url'] ?? 'assets/cattle.jpg'; // Default to local image if not available

              return {
                'name': item['post_name'] ?? 'Unknown Cattle',
                'price': item['price'] ?? 0,
                'description': item['description'] ?? 'No description available',
                'location': item['village'] ?? 'Unknown location',
                'image': item['post_url'] ?? 'assets/cattle.jpg',
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
      print('Error fetching cattle posts: $e');
    }
  }

  void toggleFavorite(Map<String, dynamic> cattleItem) {
    setState(() {
      if (favoriteItems.contains(cattleItem)) {
        favoriteItems.remove(cattleItem);
      } else {
        favoriteItems.add(cattleItem);
      }
    });
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Price: Low to High') {
        cattleItems.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (filter == 'Price: High to Low') {
        cattleItems.sort((a, b) => b['price'].compareTo(a['price']));
      }
    });
  }
  void showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              RadioListTile<String>(
                title: Text('Price: Low to High'),
                value: 'Price: Low to High',
                groupValue: selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) applyFilter(value);
                },
              ),
              RadioListTile<String>(
                title: Text('Price: High to Low'),
                value: 'Price: High to Low',
                groupValue: selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) applyFilter(value);
                },
              ),
            ],
          ),
        );
      },
    );
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
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Cattle",
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              onChanged: (value) {
                setState(() {
                  cattleItems = cattleItems
                      .where((item) => item['name']
                      .toString()
                      .toLowerCase()
                      .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_sharp, color: Colors.white, size: 30,),
            onPressed: () => showFilterDialog(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchCattlePosts,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 2.7,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: cattleItems.length,
          itemBuilder: (context, index) {
            final cattleItem = cattleItems[index];
            final isFavorited = favoriteItems.contains(cattleItem);

            return GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CattleDetailsPage(
                      name: cattleItem['name'],
                      price: '₹${cattleItem['price']}',
                      imagePath: cattleItem['image'],
                      location: cattleItem['location'] ?? 'Unknown location', // Make sure location is not null
                      description: cattleItem['description'] ?? 'No description available', // Make sure description is not null
                      FarmerName: cattleItem['FarmerName'], // Pass full name
                      Phone: cattleItem['Phone'], // Pass phone
                      review: 'This is a sample review.',
                    ),
                  ),
                );
              },
              child: CattleCard(
                name: cattleItem['name'],
                price: '₹${cattleItem['price']}',
                imagePath: cattleItem['image'],
                isFavorited: isFavorited,
                onFavoritePressed: () => toggleFavorite(cattleItem),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CattleCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isFavorited;
  final VoidCallback onFavoritePressed;

  const CattleCard({
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
          // Fixed height for the image
          SizedBox(
            height: 150, // Set a fixed height for the image
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
                  'assets/cattle'
                      '.jpg',
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2, // Allows wrapping to a maximum of 2 lines
                        overflow: TextOverflow.ellipsis, // Displays '...' if text overflows
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
