import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'add_page.dart';

class TabbedPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  TabbedPage({required this.userData,required this.phoneNumber});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Dashboard'),
          backgroundColor: Color(0xFF00AD83), // Your preferred color
          bottom: TabBar(
            indicatorColor: Colors.white, // Tab indicator color
            tabs: [
              Tab( text: 'My Posts'),
              Tab( text: 'My Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyPostPage(userData: userData,phoneNumber:phoneNumber,),
            MyTransactionPage(),
          ],
        ),
      ),
    );
  }
}

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
        builder: (context) => AddMarketPostPage(userData: {},phoneNumber: ''),
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

  const MyPostDetailsPage({
    required this.crop_name,
    required this.price,
    required this.imagePath,
    required this.location,
    required this.description,
    required this.review,
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


class MyTransactionPage extends StatefulWidget {
  @override
  _MyTransactionPageState createState() => _MyTransactionPageState();
}

class _MyTransactionPageState extends State<MyTransactionPage> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final url = Uri.parse('http://3.110.121.159/api/transaction/get_all_transcation_by_user');
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "farmer_id": "671f66a79be5547386def73e",
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          transactions = data['results'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF00AD83),
      //   title: Text('Transactions'),
      // ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? Center(
        child: Text(
          'No transactions found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final farmer = transaction['farmerDetails'][0];
          return ListTile(
            leading: Icon(
              transaction['status'] == 'sold'
                  ? Icons.check_circle
                  : Icons.hourglass_empty,
              color: transaction['status'] == 'sold'
                  ? Colors.green
                  : Colors.orange,
            ),
            title: Text('Transaction ID: ${transaction['transaction_id']}'),
            subtitle: Text(
              '${transaction['crop_name'] ?? 'N/A'} - ${farmer['full_name'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction['amount'] != null
                      ? '₹${transaction['amount']}'
                      : 'Pending Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction['amount'] != null
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction['created_at'] != null
                      ? transaction['created_at'].split('T')[0]
                      : 'Date N/A',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionDetailPage(transaction: transaction),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  TransactionDetailPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final farmer = transaction['farmerDetails'][0];
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
        backgroundColor: Color(0xFF00AD83),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Transaction Info'),
            _buildDetailCard('Transaction ID:', transaction['transaction_id']),
            _buildDetailCard('Crop Name:', transaction['crop_name']),
            _buildDetailCard('Status:', transaction['status']),
            _buildDetailCard('Amount:', transaction['amount'] != null ? '₹${transaction['amount']}' : 'Pending Amount'),
            // _buildDetailCard(
            //   'Transaction Date:',
            //   transaction['created_at'].substring(0, 10),
            // ),
            _buildDetailCard(
              'Transaction Date:',
              transaction['created_at'] != null ? transaction['created_at'].substring(0, 10) : 'Date N/A',
            ),
            SizedBox(height: 20),

            _buildSectionTitle('Farmer Details'),
            _buildDetailCard('Name:', farmer['full_name']),
            _buildDetailCard('Phone:', farmer['phone']),
            _buildDetailCard('Village:', farmer['village']),
            _buildDetailCard('Taluka:', farmer['taluka']),
            _buildDetailCard('District:', farmer['district']),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildDetailCard(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value ?? 'N/A', // Provide a fallback for null values
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
