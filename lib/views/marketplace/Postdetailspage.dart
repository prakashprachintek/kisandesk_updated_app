import 'package:flutter/material.dart';
import 'package:mainproject1/views/services/image_caching.dart';
import 'package:share_plus/share_plus.dart'; 

class Postdetailspage extends StatefulWidget {
  final String name;
  final String price;
  final String imagePath;
  final String location;
  final String description;
  final String review;
  final String FarmerName; 
  final String Phone; 

  const Postdetailspage({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.location,
    required this.description,
    required this.review,
    required this.FarmerName,
    required this.Phone,

    super.key,
  });

  @override
  _PostdetailspageState createState() => _PostdetailspageState();
}

class _PostdetailspageState extends State<Postdetailspage> {
  final double _selectedRating = 0.0;


  void _shareProductDetails() {
    String productDetails = 'Check out this machinery: ${widget.name}\n'
        'Price: ${widget.price}\n'
        'Location: ${widget.location}\n'
        'Description: ${widget.description}\n'
        'Farmer Name: ${widget.FarmerName}\n'
        'Phone: ${widget.Phone}\n'
        'Rating: $_selectedRating stars\n';

    Share.share(productDetails);
  }


  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black, size: 24), 
          const SizedBox(width: 15), 
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black), 
                children: <TextSpan>[
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About this post',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareProductDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedImageWidget(
                imageUrl: widget.imagePath,
                fit: BoxFit.cover,
                height: 240,
              ),
            ),
            // Container(
            //   height: 240,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(12),
            //     image: DecorationImage(
            //       image: NetworkImage(widget.imagePath),
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 30), 
            Align(
              alignment: Alignment.center,
              child: Text(
                'Price: ₹${widget.price}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30), 
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: widget.location,
                    ),
                    _buildDetailRow(
                      icon: Icons.list, 
                      label: 'Description',
                      value: widget.description,
                    ),
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Farmer Name',
                      value: widget.FarmerName,
                    ),
                    _buildDetailRow(
                      icon: Icons.call,
                      label: 'Phone',
                      value: widget.Phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}