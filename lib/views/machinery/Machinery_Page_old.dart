import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'machinerydetailspage.dart';

class MachineryPage extends StatefulWidget {
  @override
  _MachineryPageState createState() => _MachineryPageState();
}

class _MachineryPageState extends State<MachineryPage> {
  List<Map<String, dynamic>> machineryItems =
      []; // List to store machinery items
  List<Map<String, dynamic>> favoriteItems =
      []; // List to store favorite machinery items
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  String selectedFilter = '';

  @override
  void initState() {
    super.initState();
    fetchMachineryPosts();
  }

  // Fetch machinery posts from API
  Future<void> fetchMachineryPosts() async {
    const String url =
        'http://13.233.103.50/api/admin/getAll_market_post'; // Replace with your API endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "", // Adjust the category for machinery
          "search": "",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results']; // Accessing the results key
        if (results != null) {
          setState(() {
            machineryItems = results.map<Map<String, dynamic>>((item) {
              final farmerDetails =
                  (item['farmerDetails'] as List?)?.isNotEmpty == true
                      ? item['farmerDetails'][0]
                      : null;

              return {
                'name': item['post_name'] ?? 'Unknown Machinery',
                'price': item['price'] ?? 0,
                'description':
                    item['description'] ?? 'No description available',
                'location': item['village'] ?? 'Unknown location',
                'image': item['post_url'] ?? 'assets/machinery1.webp',
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

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Price: Low to High') {
        machineryItems.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (filter == 'Price: High to Low') {
        machineryItems.sort((a, b) => b['price'].compareTo(a['price']));
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
              onChanged: (value) {
                setState(() {
                  machineryItems = machineryItems
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
          : machineryItems.isEmpty
              ? Center(child: Text('No machinery posts found.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 2.7,
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
                                location: machineryItem['location'] ??
                                    'Unknown location', // Make sure location is not null
                                description: machineryItem['description'] ??
                                    'No description available', // Make sure description is not null
                                FarmerName: machineryItem[
                                    'FarmerName'], // Pass full name
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
                          onFavoritePressed: () =>
                              toggleFavorite(machineryItem),
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
