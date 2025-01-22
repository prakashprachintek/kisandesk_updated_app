import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'CattleDetailsPage.dart';
import 'favoritePage.dart';
import 'Cropdetails_page.dart';

class CropsPage extends StatefulWidget {
  @override
  _CropsPageState createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  List<Map<String, dynamic>> CropsItems = [];
  List<Map<String, dynamic>> favoriteItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCropsPosts();
  }

  Future<void> fetchCropsPosts() async {


    const String url = 'http://3.110.121.159/api/admin/getAll_market_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "adati",
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
            CropsItems =  results.map<Map<String, dynamic>>((item) {
              final farmerDetails = (item['farmerDetails'] as List?)?.isNotEmpty == true
                  ? item['farmerDetails'][0]
                  : null;

              return {
                'name': item['post_name'] ?? 'Unknown Machinery',
                'price': item['price'] ?? 0,
                'description': item['description'] ?? 'No description available',
                'location': item['village'] ?? 'Unknown location',
                'image': item['image'] ?? 'assets/rice1.jpg',
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
      print('Error fetching Crops posts: $e');
    }
  }

  void toggleFavorite(Map<String, dynamic> CropsItem) {
    setState(() {
      if (favoriteItems.contains(CropsItem)) {
        favoriteItems.remove(CropsItem);
      } else {
        favoriteItems.add(CropsItem);
      }
    });
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
            ),
          ),
        ),
        // Removed favorite button from actions
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
              onPressed: fetchCropsPosts,
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
            childAspectRatio: 2 / 2.5,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: CropsItems.length,
          itemBuilder: (context, index) {
            final CropsItem = CropsItems[index];

            return GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CropsDetailsPage(
                      name: CropsItem['name'],
                      quantity: '${CropsItem['quantity']} kg',
                      price: '₹${CropsItem['price']}',
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
              child:CropsCard(
                name: CropsItem['name'],
                price: '₹${CropsItem['price']}',
                quantity: '${CropsItem['quantity']} kg', // Replace 'kg' with appropriate unit
                imagePath: CropsItem['image'],
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
