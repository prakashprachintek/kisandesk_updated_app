import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/api_config.dart';
import 'Postdetailspage.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<Map<String, dynamic>> marketItems =
      []; // List to store market items
  List<Map<String, dynamic>> favoriteItems =
      []; // List to store favorite market items
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  String selectedFilter = '';

  @override
  void initState() {
    super.initState();
    fetchMarketPosts();
  }

  // Fetch market posts from API
  Future<void> fetchMarketPosts() async {
    const String url =
        '${KD.api}/admin/getAll_market_post'; // Replace with your API endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "", // Adjust the category for market
          "search": "",
          
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results']; // Accessing the results key
        if (results != null) {
          setState(() {
            marketItems = results.map<Map<String, dynamic>>((item) {
              final farmerDetails =
                  (item['farmerDetails'] as List?)?.isNotEmpty == true
                      ? item['farmerDetails'][0]
                      : null;

              return {
                'name': item['post_name'] ?? 'Unknown market',
                'price': item['price'] ?? 0,
                'description':
                    item['description'] ?? 'No description available',
                'location': item['village'] ?? 'Unknown location',
                'image': item['post_url'] ?? 'assets/market1.webp',
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
      print('Error fetching market posts: $e');
    }
  }

  void toggleFavorite(Map<String, dynamic> marketItem) {
    setState(() {
      if (favoriteItems.contains(marketItem)) {
        favoriteItems.remove(marketItem);
      } else {
        favoriteItems.add(marketItem);
      }
    });
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Price: Low to High') {
        marketItems.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (filter == 'Price: High to Low') {
        marketItems.sort((a, b) => b['price'].compareTo(a['price']));
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
                hintText: "Search market",
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color.fromRGBO(255, 255, 255, 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              onChanged: (value) {
                setState(() {
                  marketItems = marketItems
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
            icon: Icon(
              Icons.filter_list_sharp,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => showFilterDialog(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : marketItems.isEmpty
              ? Center(child: Text('No market posts found.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 2.7,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: marketItems.length,
                    itemBuilder: (context, index) {
                      final marketItem = marketItems[index];
                      final isFavorited = favoriteItems.contains(marketItem);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Postdetailspage(
                                name: marketItem['name'],
                                price: '₹${marketItem['price']}',
                                imagePath: marketItem['image'],
                                location: marketItem['location'] ??
                                    'Unknown location', // Make sure location is not null
                                description: marketItem['description'] ??
                                    'No description available', // Make sure description is not null
                                FarmerName: marketItem[
                                    'FarmerName'], // Pass full name
                                Phone: marketItem['Phone'], // Pass phone
                                review: 'This is a sample review.',
                              ),
                            ),
                          );
                        },
                        child: MarketCard(
                          name: marketItem['name'],
                          price: '₹${marketItem['price']}',
                          imagePath: marketItem['image'],
                          isFavorited: isFavorited,
                          onFavoritePressed: () =>
                              toggleFavorite(marketItem),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class MarketCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isFavorited;
  final VoidCallback onFavoritePressed;

  const MarketCard({
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
                        overflow: TextOverflow
                            .ellipsis, // Displays '...' if text overflows
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
