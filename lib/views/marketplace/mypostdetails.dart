import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mainproject1/views/other/add_page.dart'; 
import '../services/api_config.dart'; 
import '../services/user_session.dart'; 
import 'Market_page.dart'; 
import 'Postdetailspage.dart'; 


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
          errorMessage = 'User_not_logged_in._Cannot_fetch_posts.'.tr();
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

    final cacheKey = 'data_my_posts_$userId';
    final timestampKey = 'last_updated_my_posts_$userId';

    await cacheBox.delete(cacheKey);
    await cacheBox.delete(timestampKey);

    await _loadFromCacheOrFetch(forceNetwork: true);
  }



  Future<void> _loadFromCacheOrFetch({required bool forceNetwork}) async {
    final userId = UserSession.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'User_not_logged_in._Cannot_fetch_posts.'.tr();
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
                errorMessage = null;
              });
            }
            return;
          }
        }
        print('❌ Cache is stale or non-existent, fetching from API.');
      } catch (e) {
        print('⚠️ Error reading cache: $e');
      }
    }


    await _fetchMyPosts(isBackground: false);
  }


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
          errorMessage = 'User_not_logged_in._Cannot_fetch_posts.'.tr();
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


  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm_Deletion').tr(),
              content: const Text(
                  'Are_you_sure_you_want_to_delete_this_post?_This_cannot_be_undone.').tr(),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel').tr(),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('delete',
                      style: TextStyle(color: Colors.white)).tr(),
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
                content: Text(data['message'] ?? 'Post_deleted_successfully!'.tr)),
          );


          setState(() {
            myPosts.removeWhere((post) => post['_id'] == postId);
          });


          final cacheKey = 'data_my_posts_$userId';
          final now = DateTime.now().toString();
          await cacheBox.put(cacheKey, myPosts);
          await cacheBox.put('last_updated_my_posts_$userId', now);
        }
      } else {
        throw Exception(data['message'] ?? 'Failed_to_delete_post._Unknown_server_error.'.tr());
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



  @override
  Widget build(BuildContext context) {
    final userSessionData = UserSession.user ?? {};
    final phone = userSessionData['phone'] ?? '';
    final isUserLoggedIn = UserSession.userId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('myPost').tr(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = UserSession.userId;
          if (userId != null) {
            await cacheBox.delete('data_my_posts_$userId');
            await cacheBox.delete('last_updated_my_posts_$userId');
          }
          await _loadFromCacheOrFetch(forceNetwork: true);
        },
        child: _buildBody(),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMarketPostPage(
                userData: userSessionData,
                phoneNumber: phone,
                isUserExists: isUserLoggedIn,
              ),
            ),
          );
          
          if (result == true) {
             await _loadFromCacheOrFetch(forceNetwork: true);
          }
        },
        tooltip: 'Create_New_Post'.tr(),
        child: const Icon(Icons.add),
      ),

    );
  }



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
        message: 'You_have_not_created_any_market_posts_yet.'.tr(),
        subMessage: 'Tap_the_(+)_button_on_the_home_screen_to_create_one.'.tr(),
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
                          price: '${post['price']}',
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
              style: const TextStyle(fontSize: 16, color: Colors.black54),
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
                child: const Text('Try_Again').tr(),
              ),
          ],
        ),
      ),
    );
  }
}