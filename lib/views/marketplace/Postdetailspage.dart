import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus package

class Postdetailspage extends StatefulWidget {
  final String name;
  final String price;
  final String imagePath; // Main image from API
  final String location;
  final String description;
  final String review;
  final String FarmerName; // Farmer's name
  final String Phone; // Phone number

  const Postdetailspage({
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
  _PostdetailspageState createState() => _PostdetailspageState();
}

class _PostdetailspageState extends State<Postdetailspage> {
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
          'About this post',
          style: TextStyle(color: Colors.white),
        ),
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
