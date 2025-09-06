import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import 'Postdetailspage.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<Map<String, dynamic>> marketItems = [];
  List<Map<String, dynamic>> originalMarketItems = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String selectedFilter = '';

  @override
  void initState() {
    super.initState();
    fetchMarketPosts();
  }

  Future<void> fetchMarketPosts() async {
    const String url = '${KD.api}/admin/getAll_market_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": "",
          "search": "",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'];
        if (results != null) {
          setState(() {
            originalMarketItems = List<Map<String, dynamic>>.from(
                results.map<Map<String, dynamic>>((item) {
              final farmerDetails =
                  (item['farmerDetails'] as List?)?.isNotEmpty == true
                      ? item['farmerDetails'][0]
                      : null;

              return {
                'name': item['post_name'] ?? 'Unknown market',
                'price': item['price'] ?? 0,
                'description':
                    item['description'] ?? 'No description available',
                'location': item['village'] ?? 'Unknown location',
                'fileName': item['post_url'] ?? 'assets/market1.webp',
                'quantity' : item['quantity'] ?? 'N/A',
                'FarmerName': farmerDetails?['full_name'] ?? 'Unknown Farmer',
                'Phone': farmerDetails?['phone'] ?? 'N/A',
                'taluka': farmerDetails?['taluka'] ?? 'N/A',
                
              };
            }).toList());
            marketItems = List.from(originalMarketItems);
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
        marketItems = [];
      });
      print('Error fetching market posts: $e');
    }
  }

  void _performSearchAndFilter() {
    List<Map<String, dynamic>> filteredList = List.from(originalMarketItems);

    String query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredList = filteredList
          .where(
              (item) => item['name'].toString().toLowerCase().contains(query))
          .toList();
    }

    if (selectedFilter == 'Price: Low to High') {
      filteredList.sort((a, b) {
        final aPrice = a['price'] is num ? a['price'] as num : 0;
        final bPrice = b['price'] is num ? b['price'] as num : 0;
        return aPrice.compareTo(bPrice);
      });
    } else if (selectedFilter == 'Price: High to Low') {
      filteredList.sort((a, b) {
        final aPrice = a['price'] is num ? a['price'] as num : 0;
        final bPrice = b['price'] is num ? b['price'] as num : 0;
        return bPrice.compareTo(aPrice);
      });
    }

    setState(() {
      marketItems = filteredList;
    });

    
    print('Filtered items: ${filteredList.length}');
    filteredList.forEach(
        (item) => print('Item: ${item['name']}, Price: ${item['price']}'));
  }

  void showFilterDialog(BuildContext context) async {
    final newFilter = await showModalBottomSheet<String>(
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
                  Navigator.pop(context, value); // Pass the selected value back
                },
              ),
              RadioListTile<String>(
                title: Text('Price: High to Low'),
                value: 'Price: High to Low',
                groupValue: selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context, value); // Pass the selected value back
                },
              ),
            ],
          ),
        );
      },
    );

    // This code runs only after the modal sheet is closed.
    if (newFilter != null && newFilter != selectedFilter) {
      setState(() {
        selectedFilter = newFilter;
      });
      _performSearchAndFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            height: 40,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search market",
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color.fromRGBO(255, 255, 255, 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              onChanged: (value) {
                _performSearchAndFilter();
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
          : marketItems.isEmpty
              ? Center(child: Text('No market posts found.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 2.7,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: marketItems.length,
                    itemBuilder: (context, index) {
                      final marketItem = marketItems[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Postdetailspage(
                                name: marketItem['name'],
                                price: '₹${marketItem['price']}',
                                imagePath: marketItem['fileName'],
                                location: marketItem['location'] ??
                                    'Unknown location',
                                description: marketItem['description'] ??
                                    'No description available',
                                FarmerName: marketItem['FarmerName'],
                                Phone: marketItem['Phone'],
                                review: 'This is a sample review.',
                                // quantity: marketItem['quantity'],
                              ),
                            ),
                          );
                        },
                        child: MarketCard(
                          name: marketItem['name'],
                          taluka: marketItem['taluka'] ?? 'N/A',
                          price: '₹${marketItem['price']}',
                          imagePath: marketItem['fileName'],
                          //taluka: marketItem['taluka'] ?? 'N/A',
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class MarketCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final String taluka;

  const MarketCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.taluka,
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
            height: 120,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/land1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        taluka,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
