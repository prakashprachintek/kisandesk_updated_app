import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/other/add_page.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class MyPostPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  MyPostPage({required this.userData,required this.phoneNumber});
  @override
  _MyPostPageState createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  List<Map<String, dynamic>> myPostItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMarketPosts();
  }

  Future<void> fetchMarketPosts() async {
    final url = Uri.parse('http://3.110.121.159/api/admin/fetchpost_by_userid');
    final Map<String, String> requestBody = {
      "user_id": widget.userData['farmer_id'],
    };

    print('Requesting posts for user_id: ${requestBody["user_id"]}');

    try {
      setState(() {
        isLoading = true; // Indicate loading
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success' && responseData['results'] != null) {
          final List<dynamic> data = responseData['results'];
          setState(() {
            myPostItems = data.map((item) => Map<String, dynamic>.from(item)).toList();
            isLoading = false; // Stop loading once data is fetched
          });
        } else {
          setState(() {
            isLoading = false; // Stop loading if no data
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No data found. Please try again later.')),
          );
        }
      } else {
        setState(() {
          isLoading = false; // Stop loading on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts. Status code: ${response.statusCode}')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Stop loading on network error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please check your connection.')),
      );
    }
  }


  void toggleFavorite(Map<String, dynamic> item) {
    // Implement favorite toggle functionality
  }

  void editItem(Map<String, dynamic> item) {
    // Navigate to AddPage for editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMarketPostPage(userData: {},phoneNumber: '', isUserExists: true,),
      ),
    );
  }

  void deleteItem(int index) {
    setState(() {
      myPostItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83), // Customize AppBar color
        title: Text('mypost'),
      ),

      body:  isLoading
          ? Center(child: CircularProgressIndicator())
          : myPostItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 50,
              color: Colors.grey,
            ),
            Text(
              'No posts added yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            // Text(
            //   '👉 Please add a post to get started!',
            //   style: TextStyle(fontSize: 16, color: Colors.grey),
            // ),
          ],
        ),
      )
          :Padding(
        padding: const EdgeInsets.all(16.0),
        child:  GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 2.5,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: myPostItems.length,
          itemBuilder: (context, index) {
            final myPostItem = myPostItems[index];
            final farmerDetails = myPostItem['farmerDetails']?.isNotEmpty == true
                ? myPostItem['farmerDetails'][0]
                : null;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPostDetailsPage(
                      crop_name: myPostItem['post_name'] ?? 'N/A',
                      price: '₹${myPostItem['price'] ?? '0'}',
                      imagePath: myPostItem['image'] ?? 'assets/rice1.jpg',
                      location: myPostItem['village'] ?? 'N/A',
                      description: myPostItem['description'] ?? 'No description provided.',
                      FarmerName: farmerDetails?['full_name'] ?? 'Unknown',
                      Phone: farmerDetails?['phone'] ?? 'N/A',
                      review: 'Sample review here.',
                    ),
                  ),
                );
              },
              child: MyPostCard(
                crop_name: myPostItem['post_name'] ?? 'N/A',
                price: '₹${myPostItem['price'] ?? '0'}',
                imagePath: myPostItem['image'] ?? 'assets/default.jpg',
               // onFavoritePressed: () => toggleFavorite(myPostItem),
                onEditPressed: () => editItem(myPostItem),
                onDeletePressed: () => deleteItem(index),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyPostCard extends StatelessWidget {
  final String crop_name;
  final String price;
  final String imagePath;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const MyPostCard({
    required this.crop_name,
    required this.price,
    required this.imagePath,
    required this.onEditPressed,
    required this.onDeletePressed,
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
                  'assets/rice1.jpg', // Placeholder image
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      crop_name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Color(0xFF00AD83)),
                          onPressed: onEditPressed,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: onDeletePressed,
                        ),
                      ],
                    ),
                  ],
                ),
               // SizedBox(height: 4),
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

class MyPostDetailsPage extends StatefulWidget {
  final String crop_name;
  final String price;
  final String imagePath;
  final String location;
  final String description;
  final String review;
  final String FarmerName; // Add full name
  final String Phone; //

  const MyPostDetailsPage({
    required this.crop_name,
    required this.price,
    required this.imagePath,
    required this.location,
    required this.description,
    required this.review,
    required this.FarmerName,
    required this.Phone,
  });

  @override
  _MyPostDetailsPageState createState() => _MyPostDetailsPageState();
}

class _MyPostDetailsPageState extends State<MyPostDetailsPage> {
  late String selectedImage;
  double _selectedRating = 0.0;

  // List of thumbnails
  final List<String> imageThumbnails = [
    'assets/dal.jpg',
    'assets/cattle2.webp',
    'assets/cattle1.jpg',
    'assets/cattle2.webp',
  ];

  @override
  void initState() {
    super.initState();
    selectedImage = widget.imagePath; // Set initial image
  }


  void _onStarTap(double rating) {
    setState(() {
      _selectedRating = rating;
    });
  }
  // Method to handle sharing the product details
  void _shareProductDetails() {
    String productDetails =
        'Check out this machinery: ${widget.crop_name}\n'
        'Price: ${widget.price}\n'
        'Location: ${widget.location}\n'
        'FarmerName: ${widget.FarmerName}\n'
        'Phone: ${widget.Phone}\n'
        'Description: ${widget.description}\n'
        'Rating: $_selectedRating stars\n';

    Share.share(productDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mypost Details',
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
                  image: AssetImage(selectedImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Image Thumbnails
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: imageThumbnails.map((image) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = image;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 1), // Reduced margin
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedImage == image
                              ? Color(0xFF00AD83)
                              : Colors.transparent,
                          width: 2),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Cattle Price, Location, and Favorite Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align price and heart icon at opposite corners
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
              'FarmerName: ${widget.FarmerName}',
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
            SizedBox(height: 10),

            // Cattle Description
            Text(
              'Description: ${widget.description}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 30),



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
                  // Star Rating System
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
                  // Star Rating Distribution (Progress Bars)
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
