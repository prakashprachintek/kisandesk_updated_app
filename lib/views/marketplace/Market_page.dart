import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mainproject1/views/marketplace/mypostdetails.dart';
import 'package:mainproject1/views/services/image_caching.dart';
import '../services/api_config.dart';
import 'Postdetailspage.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> marketItems = [];
  List<Map<String, dynamic>> originalMarketItems = [];
  bool isLoading = true;
  bool isOffline = false;
  String? lastUpdated;
  String selectedCategory = '';
  String selectedSubCategory = '';

  TextEditingController searchController = TextEditingController();
  String selectedFilter = '';
  late Box cacheBox;

  final Map<String, String> categoryImages = {
    '': 'assets/all_market.jpg',
    'crop': 'assets/cropn.png',
    'cattle': 'assets/cattlen.png',
    'machinery': 'assets/Machinen.png',
    'land': 'assets/propn.jpg'
  };

  final Map<String, String> categoryNames = {
    '': 'All',
    'crop': 'Crop',
    'cattle': 'Cattle',
    'machinery': 'Machinery',
    'land': "Properties"
  };

  // CENTRALIZED MAP for all subcategories
  final Map<String, Map<String, Map<String, String>>> subCategoriesData = {
    'cattle': {
      'cow': {'name': 'Cow', 'image': 'assets/cow.png'},
      'ox': {'name': 'Ox', 'image': 'assets/oxnew.png'},
      'buffalo': {'name': 'Buffalo', 'image': 'assets/Buffalom.png'},
      'sheep': {'name': 'Sheep', 'image': 'assets/Sheep.png'},
      'goat': {'name': 'Goat', 'image': 'assets/goat (2).png'},
      'hen': {'name': 'Hen', 'image': 'assets/Henm.png'},
      'duck': {'name': 'Duck', 'image': 'assets/Duck.png'},
    },
    'machinery': {
      'farming_machines': {
        'name': 'Farming Machines',
        'image': 'assets/FarmingMachine.png'
      },
      'farming_equipment': {
        'name': 'Farming Equipment',
        'image': 'assets/FarmingEqui.png'
      },
      'transport': {
        'name': 'Transport Vehicles',
        'image': 'assets/Transportm.png'
      },
    },
    'crop': {
      'oil_seed': {'name': 'Oil Seed', 'image': 'assets/oil_seedsm.png'},
      'vegetables': {'name': 'Vegetables', 'image': 'assets/vegetablesm.png'},
      'fruits': {'name': 'Fruits', 'image': 'assets/fruitsm.png'},
      'pulses': {'name': 'Pulses', 'image': 'assets/pulses.png'},
      'cerals': {'name': 'Cerals', 'image': 'assets/cerealsm.png'},
      'dry_fruits': {'name': 'Dry Fruits', 'image': 'assets/dryfruitsm.png'}
    },
    'land': {
      'home': {'name': 'Home', 'image': 'assets/homen.webp'},
      'dry_land': {'name': 'Dry Land', 'image': 'assets/DryLand.png'},
      'irrigation_land': {
        'name': 'Irrigation Land',
        'image': 'assets/irrigationland.png'
      },
      'plots': {'name': 'Plots', 'image': 'assets/Plots.png'},
    },
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initHiveAndFetch();
    searchController.addListener(_performSearchAndFilter);
  }

  @override
  void dispose() {
    searchController.dispose();
    _closeHiveBox();
    super.dispose();
  }

  String _normalizePostName(String? postName) {
    if (postName == null) return '';
    return postName.toLowerCase().replaceAll(' ', '_');
  }

  Future<void> _initHiveAndFetch() async {
    await Hive.initFlutter();
    cacheBox = await Hive.openBox('market_posts_box');
    print('📦 Hive box opened: market_posts_box');
    await _loadFromCacheOrFetch();
  }

  Future<void> _closeHiveBox() async {
    if (Hive.isBoxOpen('market_posts_box')) {
      await cacheBox.close();
      print('📕 Cache box closed');
    }
  }

  void _selectCategory(String category) {
    if (selectedCategory != category) {
      setState(() {
        selectedCategory = category;
        selectedSubCategory = '';
        print('🔄 Switching to category: $selectedCategory');
      });
      _loadFromCacheOrFetch();
    }
  }

  void _selectSubCategory(String subCategory) {
    final newSubCategory =
        selectedSubCategory == subCategory ? '' : subCategory;

    if (selectedSubCategory != newSubCategory) {
      setState(() {
        selectedSubCategory = newSubCategory;
        print('🔄 Switching to subcategory: $selectedSubCategory');
      });
      _performSearchAndFilter();
    }
  }

  Future<void> _loadFromCacheOrFetch() async {
    setState(() {
      isLoading = true;
    });

    final cacheKey =
        'data_${selectedCategory.isEmpty ? 'all' : selectedCategory}';
    final timestampKey =
        'last_updated_${selectedCategory.isEmpty ? 'all' : selectedCategory}';

    try {
      final cachedData = cacheBox.get(cacheKey);
      final cachedTimestamp = cacheBox.get(timestampKey);

      if (cachedData != null &&
          cachedTimestamp != null &&
          cachedData is List &&
          cachedTimestamp is String) {
        final lastUpdatedTime = DateTime.tryParse(cachedTimestamp);
        if (lastUpdatedTime != null) {
          final now = DateTime.now();
          const cacheDuration = Duration(hours: 24);

          if (now.difference(lastUpdatedTime) < cacheDuration) {
            print('✅ Cache hit for $cacheKey, timestamp: $cachedTimestamp');
            final castedData = (cachedData as List)
                .map((item) => (item as Map).cast<String, dynamic>())
                .toList();
            if (mounted) {
              setState(() {
                originalMarketItems = castedData;
                marketItems = List.from(originalMarketItems);
                lastUpdated = cachedTimestamp;
                isLoading = false;
                isOffline = false;
              });
              _performSearchAndFilter();
            }
            if (now.difference(lastUpdatedTime) > const Duration(hours: 23)) {
              print(
                  '🔄 Cache near expiration, fetching in background for $selectedCategory');
              _fetchMarketPosts(isBackground: true);
            }
            return;
          }
        }
      }
      print('❌ Cache miss or stale for $cacheKey, fetching from API');
    } catch (e) {
      print('⚠️ Error reading cache for $cacheKey: $e');
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
    print('🌐 Fetching from API for category: $selectedCategory');
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "category": selectedCategory,
              "search": "",
            }),
          )
          .timeout(const Duration(seconds: 10));

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
              'postType': _normalizePostName(item['post_name']),
            };
          }).toList());

          final cacheKey =
              'data_${selectedCategory.isEmpty ? 'all' : selectedCategory}';
          final timestampKey =
              'last_updated_${selectedCategory.isEmpty ? 'all' : selectedCategory}';
          await cacheBox.put(cacheKey, fetchedItems);
          final now = DateTime.now().toString();
          await cacheBox.put(timestampKey, now);
          print('💾 Cached data for $cacheKey at $now');

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
          print('⚠️ No results found in API response: ${response.body}');
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
      print('❌ Error fetching market posts for $selectedCategory: $e');
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
    final cacheKey =
        'data_${selectedCategory.isEmpty ? 'all' : selectedCategory}';
    final timestampKey =
        'last_updated_${selectedCategory.isEmpty ? 'all' : selectedCategory}';
    try {
      final cachedData = cacheBox.get(cacheKey);
      final cachedTimestamp = cacheBox.get(timestampKey);
      if (cachedData != null && cachedTimestamp != null && cachedData is List) {
        print('✅ Loaded cached data on failure for $cacheKey');
        final castedData = (cachedData as List)
            .map((item) => (item as Map).cast<String, dynamic>())
            .toList();
        if (mounted) {
          setState(() {
            originalMarketItems = castedData;
            marketItems = List.from(originalMarketItems);
            lastUpdated = cachedTimestamp;
            isOffline = true;
            _performSearchAndFilter();
          });
        }
      } else {
        print('❌ No valid cached data for $cacheKey');
        if (mounted) {
          setState(() {
            marketItems = [];
            originalMarketItems = [];
          });
        }
      }
    } catch (e) {
      print('⚠️ Error loading cache on failure for $cacheKey: $e');
      if (mounted) {
        setState(() {
          marketItems = [];
          originalMarketItems = [];
        });
      }
    }
  }

  void _performSearchAndFilter() {
    List<Map<String, dynamic>> filteredList = List.from(originalMarketItems);

    if (selectedCategory.isNotEmpty && selectedSubCategory.isNotEmpty) {
      final subcategoryKeys =
          subCategoriesData[selectedCategory]?.keys.toList() ?? [];

      if (subcategoryKeys.contains(selectedSubCategory)) {
        filteredList = filteredList
            .where((item) =>
                item['postType']?.toString().toLowerCase() ==
                selectedSubCategory.toLowerCase())
            .toList();
        print(
            '⚙️ Sub-filter applied: $selectedSubCategory, ${filteredList.length} items found');
      }
    }

    String query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredList = filteredList
          .where(
              (item) => item['name'].toString().toLowerCase().contains(query))
          .toList();
      print('🔍 Search applied: $query, ${filteredList.length} items found');
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

    if (mounted) {
      setState(() {
        marketItems = filteredList;
      });
    }
  }

  void showFilterDialog(BuildContext context) async {
    final newFilter = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('Price: Low to High'),
                value: 'Price: Low to High',
                groupValue: selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
              RadioListTile<String>(
                title: const Text('Price: High to Low'),
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

    final currentSubCategories = subCategoriesData[selectedCategory];
    final bool showSubCategories =
        currentSubCategories != null && currentSubCategories.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search market",
                hintStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: const Color.fromRGBO(255, 255, 255, 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list_sharp,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => showFilterDialog(context),
          ),
        ],
      ),

      // ---Button for My Posts ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyPostsPage(),
            ),
          );
        },
        label: const Text(
          'My Posts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.person),
        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),

      
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/NewLogo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              final cacheKey =
                  'data_${selectedCategory.isEmpty ? 'all' : selectedCategory}';
              final timestampKey =
                  'last_updated_${selectedCategory.isEmpty ? 'all' : selectedCategory}';
              await cacheBox.delete(cacheKey);
              await cacheBox.delete(timestampKey);
              print('🗑️ Cache cleared for $cacheKey on refresh');
              await _fetchMarketPosts();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: categoryImages.entries.map((entry) {
                        final categoryKey = entry.key;
                        final imagePath = entry.value;
                        final displayName = categoryNames[categoryKey]!;
                        final isSelected = selectedCategory == categoryKey;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: CategoryImageCard(
                            imagePath: imagePath,
                            categoryName: displayName,
                            isSelected: isSelected,
                            onTap: () => _selectCategory(categoryKey),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (showSubCategories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          ...currentSubCategories!.entries.map((entry) {
                            final subCategoryKey = entry.key;
                            final subCategoryData = entry.value;
                            final isSelected =
                                selectedSubCategory == subCategoryKey;

                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SubCategoryCard(
                                imagePath: subCategoryData['image'],
                                categoryName: subCategoryData['name']!,
                                isSelected: isSelected,
                                onTap: () => _selectSubCategory(subCategoryKey),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                if (lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      isOffline
                          ? "Showing cached data (Last updated: $lastUpdated). Pull to refresh."
                          : "Last updated: $lastUpdated",
                      style: TextStyle(
                        fontSize: 12,
                        color: isOffline ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : marketItems.isEmpty
                          ? Center(
                              child: Text(
                                  'No market posts found for ${categoryNames[selectedCategory]}${selectedSubCategory.isNotEmpty ? ' (${subCategoriesData[selectedCategory]?[selectedSubCategory]?['name'] ?? selectedSubCategory})' : ''}.'))
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                            description:
                                                marketItem['description'] ??
                                                    'No description available',
                                            FarmerName:
                                                marketItem['FarmerName'],
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
        ],
      ),
    );
  }
}

class SubCategoryCard extends StatelessWidget {
  final String? imagePath;
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  const SubCategoryCard({
    super.key,
    this.imagePath,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imagePath != null
                  ? Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          categoryName[0],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        categoryName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            categoryName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryImageCard extends StatelessWidget {
  final String imagePath;
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryImageCard({
    super.key,
    required this.imagePath,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Text(
                      categoryName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            categoryName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
class MarketCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final String taluka;
  final VoidCallback? onDelete;

  const MarketCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.taluka,
    this.onDelete,
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
              child: CachedImageWidget( 
                imageUrl: imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    if (onDelete != null)
                      SizedBox(
                        width: 30, 
                        height: 30,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Delete Post',
                        ),
                      ),
                  ],
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