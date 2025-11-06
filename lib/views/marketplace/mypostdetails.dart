import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_config.dart'; // Ensure KD.api is correctly defined here
import '../services/user_session.dart'; // Ensure UserSession.userId is available
import 'Market_page.dart'; // Ensure MarketCard is correctly defined
import 'Postdetailspage.dart'; // Ensure Postdetailspage is correctly defined

// --- API Configuration ---
const String FETCH_API_URL = '${KD.api}/admin/fetchpost_by_userid';
const String DELETE_API_URL = '${KD.api}/admin/delete_market_post';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<Map<String, dynamic>> myPosts = [];
  bool isLoading = true;
  String? errorMessage;
  String? lastUpdated;
  late Box cacheBox;
  bool _isDataInitialized = false;
  bool _isHiveInitialized = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataInitialized && _isHiveInitialized) {
      _loadDataOnPageOpen();
    }
  }

  // --- Hive Setup ---

  Future<void> _initHive() async {
    final userId = UserSession.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'User not logged in. Cannot access posts.'.tr();
        });
      }
      return;
    }

    if (!Hive.isBoxOpen('my_posts_box')) {
    }
    cacheBox = await Hive.openBox('my_posts_box');
    _isHiveInitialized = true;
    print('📦 Hive box opened: my_posts_box');

    if (mounted) {
      _loadDataOnPageOpen();
    }
  }

  Future<void> _loadDataOnPageOpen() async {
    _isDataInitialized = true;
    final userId = UserSession.userId;
    if (userId == null) return;

    // VITAL: Clear the cache keys on initial load to FORCE a network check
    final cacheKey = 'data_my_posts_$userId';
    final timestampKey = 'last_updated_my_posts_$userId';

    await cacheBox.delete(cacheKey);
    await cacheBox.delete(timestampKey);

    // Call the fetch logic, which will always hit the network since the cache is cleared.
    await _loadFromCacheOrFetch(forceNetwork: true);
  }

  // --- Data Loading Logic ---

  Future<void> _loadFromCacheOrFetch({required bool forceNetwork}) async {
    final userId = UserSession.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'User not logged in. Cannot fetch posts.';
        });
      }
      return;
    }

    if (!forceNetwork) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    final cacheKey = 'data_my_posts_$userId';
    final timestampKey = 'last_updated_my_posts_$userId';

    // 1. Try to load recent cache ONLY if not forcing network
    if (!forceNetwork) {
      try {
        final cachedData = cacheBox.get(cacheKey);
        final cachedTimestamp = cacheBox.get(timestampKey);

        if (cachedData != null && cachedTimestamp != null && cachedData is List) {
          final lastUpdatedTime = DateTime.tryParse(cachedTimestamp as String);

          // Use cache immediately if it's RECENT (< 30 minutes)
          if (lastUpdatedTime != null &&
              DateTime.now().difference(lastUpdatedTime) <
                  const Duration(minutes: 30)) {
            print('✅ Cache hit for $cacheKey, loading recent cached data.');
            final castedData = cachedData
                .map((item) => (item as Map).cast<String, dynamic>())
                .toList();
            if (mounted) {
              setState(() {
                myPosts = castedData;
                lastUpdated = cachedTimestamp;
                isLoading = false;
              });
            }
            return; // Exit, using recent cache.
          }
        }
        print('❌ Cache is stale or non-existent, fetching from API.');
      } catch (e) {
        print('⚠️ Error reading cache: $e');
      }
    }

    // 2. If recent cache fails or is stale/forced network, proceed to fetch from API.
    await _fetchMyPosts(isBackground: false);
  }

  // --- Fetch Posts ---

  Future<void> _fetchMyPosts({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    final userId = UserSession.userId;
    final cacheKey = 'data_my_posts_$userId';
    final timestampKey = 'last_updated_my_posts_$userId';

    if (userId == null) {
      if (!isBackground && mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'User not logged in. Cannot fetch posts.';
        });
      }
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(FETCH_API_URL),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"user_id": userId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultsList = (data['results'] is List) ? data['results'] : [];

        if (data['status'] == 'success') {
          final fetchedPosts = List<Map<String, dynamic>>.from(
              resultsList.map<Map<String, dynamic>>((item) {
            return {
              '_id': item['_id'],
              'name': item['post_name'] ?? 'Untitled Post',
              'price': item['price'] ?? 0,
              'description': item['description'] ?? 'No description.',
              'location': item['village'] ?? 'N/A',
              'fileName': item['post_url'] ?? 'assets/placeholder.jpg',
              'FarmerName': item['farmerDetails']?[0]['full_name'] ?? 'You',
              'Phone': item['farmerDetails']?[0]['phone'] ?? 'N/A',
              'taluka': item['farmerDetails']?[0]['taluka'] ?? 'N/A',
            };
          }).toList());

          // VITAL: Update cache with the fresh data
          await cacheBox.put(cacheKey, fetchedPosts);
          final now = DateTime.now().toString();
          await cacheBox.put(timestampKey, now);

          if (mounted && !isBackground) {
            setState(() {
              myPosts = fetchedPosts;
              isLoading = false;
              errorMessage = null;
              lastUpdated = now;
            });
          }
        } else {
          throw Exception(
              'API responded successfully but with an error status or malformed data: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to load posts (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ Error fetching posts: $e');
      if (!isBackground) {
        _loadCachedDataOnFailure(cacheKey, timestampKey);
      }
    }
  }

  // --- Load Cached Data On Failure (Unchanged) ---

  void _loadCachedDataOnFailure(String cacheKey, String timestampKey) {
    try {
      final cachedData = cacheBox.get(cacheKey);
      final cachedTimestamp = cacheBox.get(timestampKey);
      if (cachedData != null &&
          cachedTimestamp != null &&
          cachedData is List &&
          mounted) {
        print('✅ Loaded cached data on API failure for $cacheKey');
        final castedData = cachedData
            .map((item) => (item as Map).cast<String, dynamic>())
            .toList();
        setState(() {
          myPosts = castedData;
          isLoading = false;
          lastUpdated = cachedTimestamp as String;
          errorMessage = 'Could not fetch live data. Showing cached data.';
        });
      } else if (mounted) {
        print('❌ No valid cached data to load on failure.');
        setState(() {
          isLoading = false;
          myPosts = [];
          errorMessage = 'Network error or no posts found. Pull to refresh.';
        });
      }
    } catch (e) {
      print('⚠️ Severe error loading cache on failure: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'An unexpected error occurred.';
        });
      }
    }
  }

  // --- Delete Post ---

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                  'Are you sure you want to delete this post? This cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    final userId = UserSession.userId;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: User session expired. Cannot delete post')),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Attempting to delete post...'), duration: Duration(seconds: 2)),
    );

    try {
      final response = await http
          .post(
            Uri.parse(DELETE_API_URL),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "updatedBy": userId,
              "post_id": postId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? 'Post deleted successfully!')),
          );

          // 1. Remove the item from the local list
          setState(() {
            myPosts.removeWhere((post) => post['_id'] == postId);
          });

          // 2. VITAL: Overwrite the cache with the MODIFIED list immediately
          final cacheKey = 'data_my_posts_$userId';
          final now = DateTime.now().toString();
          await cacheBox.put(cacheKey, myPosts);
          await cacheBox.put('last_updated_my_posts_$userId', now);
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to delete post. Unknown server error.');
      }
    } catch (e) {
      print('❌ Delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deletion failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // --- Build Method with RefreshIndicator ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      // REFRESH INDICATOR ADDED BACK HERE
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = UserSession.userId;
          if (userId != null) {
            // Delete cache keys to FORCE the next load to be a network fetch.
            await cacheBox.delete('data_my_posts_$userId');
            await cacheBox.delete('last_updated_my_posts_$userId');
          }
          // Restart the loading process, forcing a network check
          await _loadFromCacheOrFetch(forceNetwork: true);
        },
        child: _buildBody(),
      ),
    );
  }

  // --- UI Building Methods (Unchanged) ---

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return _buildErrorOrEmptyState(
        isError: myPosts.isEmpty,
        message: myPosts.isEmpty
            ? errorMessage!
            : 'Showing cached data (Last updated: $lastUpdated). Pull down to refresh.',
        icon: myPosts.isEmpty ? Icons.error_outline : Icons.cloud_off,
        color: myPosts.isEmpty ? Colors.red : Colors.orange,
      );
    }

    if (myPosts.isEmpty) {
      return _buildErrorOrEmptyState(
        isError: false,
        message: 'You have not created any market posts yet.',
        subMessage: 'Tap the (+) button on the home screen to create one.',
        icon: Icons.post_add,
        color: Colors.grey,
      );
    }

    return Column(
      children: [
        if (lastUpdated != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Last updated: $lastUpdated',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 2.7,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                final post = myPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Postdetailspage(
                          name: post['name'],
                          price: '₹${post['price']}',
                          imagePath: post['fileName'],
                          location: post['location'],
                          description: post['description'],
                          FarmerName: post['FarmerName'],
                          Phone: post['Phone'],
                          review: 'Posted by you.',
                        ),
                      ),
                    );
                  },
                  child: MarketCard(
                    name: post['name'],
                    taluka: post['taluka'],
                    price: '₹${post['price']}',
                    imagePath: post['fileName'],
                    onDelete: post['_id'] != null && post['_id'] is String
                        ? () => _deletePost(post['_id']!)
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrEmptyState({
    required bool isError,
    required String message,
    String? subMessage,
    required IconData icon,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            if (subMessage != null) const SizedBox(height: 8),
            if (subMessage != null)
              Text(
                subMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            if (isError) const SizedBox(height: 10),
            if (isError)
              OutlinedButton(
                onPressed: () => _loadFromCacheOrFetch(forceNetwork: true),
                child: const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }
}