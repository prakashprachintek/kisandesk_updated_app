import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import '../services/api_config.dart';

class MandiRatesPage extends StatefulWidget {
  @override
  _MandiRatesPageState createState() => _MandiRatesPageState();
}

class _MandiRatesPageState extends State<MandiRatesPage>
    with AutomaticKeepAliveClientMixin {
  final String apiUrl = '${KD.api}/admin/fetch_mandi_rates';
  List<dynamic> mandiData = [];
  List<dynamic> filteredData = [];
  List<dynamic> displayedData = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isOffline = false;
  final int batchSize = 20;
  int currentIndex = 0;
  String? lastUpdated;

  String selectedCommodity = 'All';
  List<String> commodityOptions = ['All'];
  String selectedMarket = 'All';
  List<String> marketOptions = ['All'];

  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late Box cacheBox;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initHive();
    searchController.addListener(_debounceFilter);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          displayedData.length < filteredData.length) {
        loadMoreData();
      }
    });
  }

  Future<void> _initHive() async {
    // Initialize Hive only once with hive_flutter
    await Hive.initFlutter();
    cacheBox = await Hive.openBox('mandi_rates_box');
    await _loadFromCacheOrFetch();
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    cacheBox.close();
    super.dispose();
  }

  Timer? _debounce;
  void _debounceFilter() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), filterData);
  }

  Future<void> _loadFromCacheOrFetch() async {
    setState(() {
      isLoading = true;
    });

    // Try to load from cache
    try {
      final cachedData = cacheBox.get('data');
      final cachedCommodities = cacheBox.get('commodities');
      final cachedMarkets = cacheBox.get('markets');
      final cachedTimestamp = cacheBox.get('last_updated');

      if (cachedData != null &&
          cachedCommodities != null &&
          cachedMarkets != null &&
          cachedTimestamp != null &&
          cachedData is List &&
          cachedCommodities is List &&
          cachedMarkets is List &&
          cachedTimestamp is String) {
        final lastUpdatedTime = DateTime.tryParse(cachedTimestamp);
        if (lastUpdatedTime != null) {
          final now = DateTime.now();
          const cacheDuration = Duration(hours: 24);

          if (now.difference(lastUpdatedTime) < cacheDuration) {
            setState(() {
              mandiData = cachedData;
              commodityOptions = cachedCommodities.cast<String>();
              marketOptions = cachedMarkets.cast<String>();
              lastUpdated = cachedTimestamp;
              isLoading = false;
            });
            filterData();
            // Fetch fresh data in the background
            _fetchMandiRates();
            return;
          }
        }
      }
    } catch (e) {
      print("Error reading cache: $e");
      // Clear corrupted cache to prevent repeated issues
      await cacheBox.clear();
    }

    // No valid cache, fetch from API
    await _fetchMandiRates();
  }

  Future<void> _fetchMandiRates() async {
    try {
      final response =
          await http.post(Uri.parse(apiUrl)).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mandiData = data['results'];

          Set<String> uniqueCommodities = {};
          for (var record in mandiData) {
            if (record['Commodity'] != null) {
              uniqueCommodities.add(record['Commodity'].toString());
            }
          }
          commodityOptions = ['All'] + uniqueCommodities.toList()
            ..sort();

          Set<String> uniqueMarkets = {};
          for (var record in mandiData) {
            if (record['Market'] != null) {
              uniqueMarkets.add(record['Market'].toString());
            }
          }
          marketOptions = ['All'] + uniqueMarkets.toList()
            ..sort();

          isLoading = false;
          isOffline = false;
          lastUpdated = DateTime.now().toString();
        });

        // Cache the data
        await cacheBox.put('data', mandiData);
        await cacheBox.put('commodities', commodityOptions);
        await cacheBox.put('markets', marketOptions);
        await cacheBox.put('last_updated', lastUpdated);

        filterData();
      } else {
        print("Failed to fetch mandi rates: ${response.statusCode}");
        setState(() {
          isLoading = false;
          isOffline = true;
        });
        _loadCachedDataOnFailure();
      }
    } catch (e) {
      print("Error fetching mandi rates: $e");
      setState(() {
        isLoading = false;
        isOffline = true;
      });
      _loadCachedDataOnFailure();
    }
  }

  void _loadCachedDataOnFailure() {
    try {
      final cachedData = cacheBox.get('data');
      final cachedCommodities = cacheBox.get('commodities');
      final cachedMarkets = cacheBox.get('markets');
      final cachedTimestamp = cacheBox.get('last_updated');

      if (cachedData != null &&
          cachedCommodities != null &&
          cachedMarkets != null &&
          cachedTimestamp != null &&
          cachedData is List &&
          cachedCommodities is List &&
          cachedMarkets is List &&
          cachedTimestamp is String) {
        setState(() {
          mandiData = cachedData;
          commodityOptions = cachedCommodities.cast<String>();
          marketOptions = cachedMarkets.cast<String>();
          lastUpdated = cachedTimestamp;
          filterData();
        });
      }
    } catch (e) {
      print("Error reading cache on failure: $e");
      setState(() {
        mandiData = [];
        filteredData = [];
        displayedData = [];
        commodityOptions = ['All'];
        marketOptions = ['All'];
        lastUpdated = null;
      });
    }
  }

  void filterData() {
    final String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = mandiData.where((record) {
        final commodity = (record['Commodity'] ?? "").toLowerCase();
        final market = (record['Market'] ?? "").toLowerCase();
        final district = (record['District'] ?? "").toLowerCase();

        bool matchesCommodityFilter = selectedCommodity == 'All' ||
            commodity == selectedCommodity.toLowerCase();
        bool matchesMarketFilter =
            selectedMarket == 'All' || market == selectedMarket.toLowerCase();
        bool matchesSearchQuery = query.isEmpty ||
            commodity.contains(query) ||
            market.contains(query) ||
            district.contains(query);

        return matchesCommodityFilter &&
            matchesMarketFilter &&
            matchesSearchQuery;
      }).toList();

      currentIndex = 0;
      displayedData = filteredData.take(batchSize).toList();
      currentIndex = displayedData.length;
    });
  }

  void loadMoreData() {
    setState(() {
      isLoadingMore = true;
    });
    setState(() {
      final nextBatch =
          filteredData.skip(currentIndex).take(batchSize).toList();
      displayedData.addAll(nextBatch);
      currentIndex += nextBatch.length;
      isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchMandiRates();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Filter Options".tr(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00AD83),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Commodity'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedCommodity,
                    dropdownColor: const Color.fromARGB(255, 234, 238, 234),
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    items: commodityOptions
                        .map((commodity) => DropdownMenuItem(
                              value: commodity,
                              child: Flexible(
                                  child: Text(commodity,
                                      overflow: TextOverflow.ellipsis)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      modalSetState(() {
                        selectedCommodity = value!;
                      });
                      filterData();
                    },
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Market'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedMarket,
                    dropdownColor: const Color.fromARGB(255, 234, 238, 234),
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    items: marketOptions
                        .map((market) => DropdownMenuItem(
                              value: market,
                              child: Flexible(
                                  child: Text(market,
                                      overflow: TextOverflow.ellipsis)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      modalSetState(() {
                        selectedMarket = value!;
                      });
                      filterData();
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00AD83),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Apply Filters".tr()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mandi Rates".tr(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Color(0xFF00AD83),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- Search Bar and Filter Button ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search market, commodity, or district".tr(),
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFF00AD83)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF00AD83)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Color(0xFF00AD83), width: 2),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF00AD83),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterBottomSheet,
                      tooltip: "Open Filters",
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // --- Last Updated Info ---
              if (lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    isOffline
                        ? "Showing cached data (Last updated: $lastUpdated)."
                            .tr()
                        : "Last updated: $lastUpdated".tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isOffline ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ),
              SizedBox(height: 10),
              // --- Mandi Rates List ---
              isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF00AD83)))
                  : filteredData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("No data available for the selected filters."
                                  .tr()),
                              if (isOffline)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ElevatedButton(
                                    onPressed: _fetchMandiRates,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00AD83),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text("Retry".tr()),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                displayedData.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == displayedData.length &&
                                  isLoadingMore) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF00AD83)),
                                  ),
                                );
                              }

                              final record = displayedData[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 10),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              record['Market'] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF00AD83),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              record['Commodity'] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey.shade700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        record['District'] ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          PriceTile(
                                            label: "Min Price",
                                            value: record['Min_Price'] ?? 'N/A',
                                            color: Colors.black87,
                                          ),
                                          PriceTile(
                                            label: "Max Price",
                                            value: record['Max_Price'] ?? 'N/A',
                                            color: Colors.red.shade700,
                                          ),
                                          PriceTile(
                                            label: "Modal Price",
                                            value:
                                                record['Modal_Price'] ?? 'N/A',
                                            color: Colors.orange.shade700,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriceTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  PriceTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          "₹$value",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
