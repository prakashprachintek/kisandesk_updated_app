import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_config.dart';
import 'Postdetailspage.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> marketItems = [];
  List<Map<String, dynamic>> originalMarketItems = [];
  bool isLoading = true;
  bool isOffline = false;
  String? lastUpdated;
  String selectedCategory = ''; // Default to 'All' (empty string for API)
  
  TextEditingController searchController = TextEditingController();
  String selectedFilter = '';
  late Box cacheBox;
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _initHiveAndFetch();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        selectedCategory = _getCategoryForTab(_tabController.index);
        isLoading = true;
      });
      _loadFromCacheOrFetch();
    }
  }

  String _getCategoryForTab(int index) {
    switch (index) {
      case 0:
        return ''; // 'All'
      case 1:
        return 'crop';
      case 2:
        return 'cattle';
      case 3:
        return 'machinery';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    cacheBox.close();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initHiveAndFetch() async {
    await Hive.initFlutter();
    cacheBox = await Hive.openBox('market_posts_box_${selectedCategory}');
    await _loadFromCacheOrFetch();
  }

  Future<void> _loadFromCacheOrFetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final cachedData = cacheBox.get('data_${selectedCategory}');
      final cachedTimestamp = cacheBox.get('last_updated_${selectedCategory}');

      if (cachedData != null && cachedTimestamp != null && cachedData is List && cachedTimestamp is String) {
        final lastUpdatedTime = DateTime.tryParse(cachedTimestamp);
        if (lastUpdatedTime != null) {
          final now = DateTime.now();
          const cacheDuration = Duration(hours: 24);

          if (now.difference(lastUpdatedTime) < cacheDuration) {
            setState(() {
              originalMarketItems = List<Map<String, dynamic>>.from(cachedData);
              marketItems = List.from(originalMarketItems);
              lastUpdated = cachedTimestamp;
              isLoading = false;
            });
            _performSearchAndFilter();
            _fetchMarketPosts(isBackground: true);
            return;
          }
        }
      }
    } catch (e) {
      print("Error reading cache for $selectedCategory: $e");
      await cacheBox.clear();
    }

    await _fetchMarketPosts();
  }

  Future<void> _fetchMarketPosts({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        isLoading = true;
        isOffline = false;
      });
    }

    const String url = '${KD.api}/admin/getAll_market_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": selectedCategory,
          "search": "",
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'];
        if (results != null) {
          final fetchedItems = List<Map<String, dynamic>>.from(
              results.map<Map<String, dynamic>>((item) {
                final farmerDetails =
                    (item['farmerDetails'] as List?)?.isNotEmpty == true
                        ? item['farmerDetails'][0]
                        : null;
                return {
                  'name': item['post_name'] ?? 'Unknown market',
                  'price': item['price'] ?? 0,
                  'description': item['description'] ?? 'No description available',
                  'location': item['village'] ?? 'Unknown location',
                  'fileName': item['post_url'] ?? 'assets/market1.webp',
                  'quantity': item['quantity'] ?? 'N/A',
                  'FarmerName': farmerDetails?['full_name'] ?? 'Unknown Farmer',
                  'Phone': farmerDetails?['phone'] ?? 'N/A',
                  'taluka': farmerDetails?['taluka'] ?? 'N/A',
                };
              }).toList());

          await cacheBox.put('data_${selectedCategory}', fetchedItems);
          final now = DateTime.now().toString();
          await cacheBox.put('last_updated_${selectedCategory}', now);

          if (mounted) {
            setState(() {
              originalMarketItems = fetchedItems;
              marketItems = List.from(originalMarketItems);
              isLoading = false;
              isOffline = false;
              lastUpdated = now;
            });
            _performSearchAndFilter();
          }
        } else {
          print('No results found in response: ${response.body}');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching market posts for $selectedCategory: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          isOffline = true;
        });
        _loadCachedDataOnFailure();
      }
    }
  }

  void _loadCachedDataOnFailure() {
    try {
      final cachedData = cacheBox.get('data_${selectedCategory}');
      final cachedTimestamp = cacheBox.get('last_updated_${selectedCategory}');
      if (cachedData != null && cachedTimestamp != null && cachedData is List) {
        setState(() {
          originalMarketItems = List<Map<String, dynamic>>.from(cachedData);
          marketItems = List.from(originalMarketItems);
          lastUpdated = cachedTimestamp;
          _performSearchAndFilter();
        });
      }
    } catch (e) {
      print("Error loading cache on failure for $selectedCategory: $e");
    }
  }

  void _performSearchAndFilter() {
    List<Map<String, dynamic>> filteredList = List.from(originalMarketItems);

    String query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredList = filteredList
          .where((item) => item['name'].toString().toLowerCase().contains(query))
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
                  Navigator.pop(context, value);
                },
              ),
              RadioListTile<String>(
                title: Text('Price: High to Low'),
                value: 'Price: High to Low',
                groupValue: selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
            ],
          ),
        );
      },
    );

    if (newFilter != null && newFilter != selectedFilter) {
      setState(() {
        selectedFilter = newFilter;
      });
      _performSearchAndFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Crop'),
            Tab(text: 'Cattle'),
            Tab(text: 'Machinery'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchMarketPosts(),
        child: Column(
          children: [
            if (lastUpdated != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isOffline
                      ? "Showing cached data (Last updated: $lastUpdated)."
                      : "Last updated: $lastUpdated",
                  style: TextStyle(
                    fontSize: 12,
                    color: isOffline ? Colors.red : Colors.grey[600],
                  ),
                ),
              ),
            Expanded(
              child: isLoading
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
                                        location: marketItem['location'] ?? 'Unknown location',
                                        description: marketItem['description'] ?? 'No description available',
                                        FarmerName: marketItem['FarmerName'],
                                        Phone: marketItem['Phone'],
                                        review: 'This is a sample review.',
                                      ),
                                    ),
                                  );
                                },
                                child: MarketCard(
                                  name: marketItem['name'],
                                  taluka: marketItem['taluka'] ?? 'N/A',
                                  price: '₹${marketItem['price']}',
                                  imagePath: marketItem['fileName'],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
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