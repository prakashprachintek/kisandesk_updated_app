import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'add_page.dart';

class postPage extends StatefulWidget {
  @override
  _postPageState createState() => _postPageState();
}

class _postPageState extends State<postPage> {
  List<Map<String, dynamic>> postItems = []; // List to store machinery items
  List<Map<String, dynamic>> favoriteItems = []; // List to store favorite machinery items
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  // Fetch machinery posts from API
  Future<void> fetchPosts() async {
    const String url = 'http://3.110.121.159/api/admin/getAll_market_post'; // Replace with your API endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "",  // Adjust the category for machinery
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
            postItems = results.map<Map<String, dynamic>>((item) {
              final farmerDetails = (item['farmerDetails'] as List?)?.isNotEmpty == true
                  ? item['farmerDetails'][0]
                  : null;

              return {
                'name': item['post_name'] ?? 'Unknown Machinery',
                'price': item['price'] ?? 0,
                'description': item['description'] ?? 'No description available',
                'location': item['village'] ?? 'Unknown location',
                'image': item['post_url'] ?? 'assets/dal.jpg',
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
      print('Error fetching  posts: $e');
    }
  }

  void toggleFavorite(Map<String, dynamic> postItem) {
    setState(() {
      if (favoriteItems.contains(postItem)) {
        favoriteItems.remove(postItem);
      } else {
        favoriteItems.add(postItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : postItems.isEmpty
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
          itemCount: postItems.length,
          itemBuilder: (context, index) {
            final postItem = postItems[index];
            final isFavorited = favoriteItems.contains(postItems);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => postdetailspage(
                      name: postItem['name'],
                      price: '₹${postItem['price']}',
                      imagePath: postItem['image'],
                      location: postItem['location'] ?? 'Unknown location', // Make sure location is not null
                      description: postItem['description'] ?? 'No description available', // Make sure description is not null
                      FarmerName: postItem['FarmerName'], // Pass full name
                      Phone: postItem['Phone'], // Pass phone
                      review: 'This is a sample review.',
                    ),
                  ),
                );
              },
              child: postCard(
                name: postItem['name'],
                price: '₹${postItem['price']}',
                imagePath: postItem['image'],
                isFavorited: isFavorited,
                onFavoritePressed: () => toggleFavorite(postItem),
              ),
            );
          },
        ),
      ),
    );
  }
}

class postCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isFavorited;
  final VoidCallback onFavoritePressed;

  const postCard({
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
                        maxLines: 1, // Allows wrapping to a maximum of 2 lines
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

class postdetailspage extends StatefulWidget {
  final String name;
  final String price;
  final String imagePath; // Main image from API
  final String location;
  final String description;
  final String review;
  final String FarmerName; // Farmer's name
  final String Phone; // Phone number

  const postdetailspage({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.location,
    required this.description,
    required this.review,
    required this.FarmerName,
    required this.Phone,
  });

  @override
  _postdetailspageState createState() => _postdetailspageState();
}

class _postdetailspageState extends State<postdetailspage> {
  double _selectedRating = 0.0;

  void _onStarTap(double rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  // Method to handle sharing the product details
  void _shareProductDetails() {
    String productDetails =
        'Check out this machinery: ${widget.name}\n'
        'Price: ${widget.price}\n'
        'Location: ${widget.location}\n'
        'Description: ${widget.description}\n'
        'Farmer Name: ${widget.FarmerName}\n'
        'Phone: ${widget.Phone}\n'
        'Rating: $_selectedRating stars\n';

    Share.share(productDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'postdetails',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00AD83),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareProductDetails, // Call share functionality
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Image
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Price, Location, and Favorite Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price: ${widget.price}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Color(0xFF00AD83)),
                  onPressed: () {
                    // Add favorite functionality here
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Location: ${widget.location}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${widget.description}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Farmer Name: ${widget.FarmerName}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: ${widget.Phone}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),

            // Review Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.review,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => _onStarTap(index + 1.0),
                        child: Icon(
                          Icons.star,
                          color: index < _selectedRating
                              ? Colors.amber
                              : Colors.grey,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(5, (index) {
                      return Row(
                        children: [
                          Text('${index + 1} star:'),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 150,
                            child: LinearProgressIndicator(
                              value: (_selectedRating >= index + 1) ? 1.0 : 0.0,
                              backgroundColor: Colors.grey[300],
                              color: Color(0xFF00AD83),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


