import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus package



class Pesticidesdetailspage extends StatefulWidget {
  final String name;
  final String price;
  final String imagePath;
  final String location;
  final String description;
  final String review;

  const Pesticidesdetailspage({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.location,
    required this.description,
    required this.review,
  });

  @override
  _PesticidesdetailspageState createState() => _PesticidesdetailspageState();
}

class _PesticidesdetailspageState extends State<Pesticidesdetailspage> {
  late String selectedImage;
  double _selectedRating = 0.0;

  // List of thumbnails
  final List<String> imageThumbnails = [
    'assets/pesticides1.webp',
    'assets/pesticide2.webp',
    'assets/pesticides1.webp',
    'assets/pesticide2.webp',
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
        'Check out this machinery: ${widget.name}\n'
        'Price: ${widget.price}\n'
        'Location: ${widget.location}\n'
        'Description: ${widget.description}\n'
        'Rating: $_selectedRating stars\n';

    Share.share(productDetails);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pesticides',
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

            // Cattle Description
            Text(
              'Description: ${widget.description}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 30),

            // Add to Cart and Buy Now Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00AD83),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text("Add to Cart"),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Buy now functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text("Buy Now"),
                  ),
                ),
              ],
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
