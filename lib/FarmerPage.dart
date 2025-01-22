import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Cropdetails_page.dart';
import 'machinerydetailspage.dart';
import 'favoritePage.dart';

class CropsPage  extends StatefulWidget {
  @override
  _CropsPageState createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage > {
  List<Map<String, dynamic>> CropsItems  = []; // List to store machinery items
  List<Map<String, dynamic>> favoriteItems = []; // List to store favorite machinery items
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
    const String url = 'http://3.110.121.159/api/admin/getAll_market_post'; // Replace with your API endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "crop",  // Adjust the category for machinery
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
            CropsItems  = results.map<Map<String, dynamic>>((item) {
              final farmerDetails = (item['farmerDetails'] as List?)?.isNotEmpty == true
                  ? item['farmerDetails'][0]
                  : null;

              return {
                'name': item['post_name'] ?? 'Unknown Machinery',
                'price': item['price'] ?? 0,
                'quantity':item['quantity'] ?? 0,
                'description': item['description'] ?? 'No description available',
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
        CropsItems .sort((a, b) => a['price'].compareTo(b['price']));
      } else if (filter == 'Price: High to Low') {
        CropsItems .sort((a, b) => b['price'].compareTo(a['price']));
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
                hintText: "Search Crops",
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
                  CropsItems  = CropsItems
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
          : CropsItems .isEmpty
          ? Center(child: Text('No machinery posts found.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 2.9,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: CropsItems .length,
          itemBuilder: (context, index) {
            final CropsItem = CropsItems[index];
            final isFavorited = favoriteItems.contains(CropsItem);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CropsDetailsPage(
                      name: CropsItem['name'],
                      price: '₹${CropsItem['price']}',
                      quantity: '${CropsItem['quantity']} kg',
                      imagePath: CropsItem['image'],
                      location: CropsItem['location'] ?? 'Unknown location', // Make sure location is not null
                      description: CropsItem['description'] ?? 'No description available', // Make sure description is not null
                      FarmerName: CropsItem['FarmerName'], // Pass full name
                      Phone: CropsItem['Phone'], // Pass phone
                      review: 'This is a sample review.',
                    ),
                  ),
                );
              },
              child: CropsCard(
                name: CropsItem['name'],
                price: '₹${CropsItem['price']}',
                imagePath: CropsItem['image'],
                quantity: '${CropsItem['quantity']} kg', // Replace 'kg' with appropriate unit
                // isFavorited: isFavorited,
                // onFavoritePressed: () => toggleFavorite(CropsItem),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CropsCard extends StatelessWidget {
  final String name;
  final String price;
  final String quantity;
  final String imagePath;

  const CropsCard({
    required this.name,
    required this.price,
    required this.quantity,
    required this.imagePath,
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
                  'assets/rice.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                  "Quantity: $quantity",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
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
          ),
        ],
      ),
    );
  }
}
