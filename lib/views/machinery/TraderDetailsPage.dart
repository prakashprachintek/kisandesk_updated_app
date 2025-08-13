import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart'; // Add the share_plus import
import 'package:url_launcher/url_launcher.dart';



class TraderDetailsPage extends StatefulWidget {
  final String shopName;
  final String Address;
  final String contactDetails;
  final String location;
  final String review;
  final String share;
  final List<String> imageAssets;
  final double latitude;
  final double longitude;

  TraderDetailsPage({
    required this.shopName,
    required this.contactDetails,
    required this.location,
    required this.review,
    required this.imageAssets,
    required this.share,
    required this.latitude,
    required this.longitude,
    required this.Address,
  });

  @override
  _TraderDetailsPageState createState() => _TraderDetailsPageState();
}

class _TraderDetailsPageState extends State<TraderDetailsPage> {
  int _currentImageIndex = 0;
  double _selectedRating = 4.0;
  GoogleMapController? _mapController;

  void _onThumbnailTap(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  void _onStarTap(double rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  // Function to open Google Maps app with the provided location
  void _launchGoogleMaps(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  // Function to share trader's shop details
  void _shareTraderDetails() {
    final String traderDetails = '''
Shop Name: ${widget.shopName}
Contact: ${widget.contactDetails}
Address: ${widget.Address}
Location: ${widget.location}
''';

    Share.share(traderDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trader Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00AD83),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareTraderDetails, // Use the share function here
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      child: Image.asset(
                        widget.imageAssets[_currentImageIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
              child: Image.asset(
                widget.imageAssets[_currentImageIndex],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),

            // Image thumbnails
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: widget.imageAssets.asMap().entries.map((entry) {
                    int index = entry.key;
                    String assetPath = entry.value;
                    return GestureDetector(
                      onTap: () => _onThumbnailTap(index),
                      child: Container(
                        width: 80,
                        height: 85,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentImageIndex == index
                                ? Color(0xFF00AD83)
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.shopName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.phone, color: Color(0xFF00AD83)),
                  SizedBox(width: 8),
                  Text(
                    widget.contactDetails,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.Address,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Google Map Section
            GestureDetector(
              onTap: () {
                _launchGoogleMaps(widget.latitude, widget.longitude);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: 18.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            ProductDetails(
              imageUrl: 'assets/rice.jpg',
              productName: 'Rice',
              productPrice: '15.99',
            ),
            ProductDetails(
              imageUrl: 'assets/weat.webp',
              productName: 'Weat',
              productPrice: '12.50',
            ),
            ProductDetails(
              imageUrl: 'assets/dal.jpg',
              productName: 'Dal',
              productPrice: '18.00',
            ),

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
                              value: (_selectedRating >= index + 1)
                                  ? 1.0
                                  : 0.0,
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

class ProductDetails extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String productPrice;

  ProductDetails({
    required this.imageUrl,
    required this.productName,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$' + productPrice,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}