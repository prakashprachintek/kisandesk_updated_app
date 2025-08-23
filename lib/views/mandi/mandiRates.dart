import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class MandiRatesPage extends StatefulWidget {
  @override
  _MandiRatesPageState createState() => _MandiRatesPageState();
}

class _MandiRatesPageState extends State<MandiRatesPage>
    with AutomaticKeepAliveClientMixin {
  // final String apiUrl = '${KD.api}/admin/fetch_mandi_rates';
  List<dynamic> mandiData = [];
  List<dynamic> filteredData = [];
  List<dynamic> displayedData = []; // Subset of filteredData for lazy loading
  bool isLoading = true;
  bool isLoadingMore = false;
  final int batchSize = 20; // Number of items to load per batch
  int currentIndex = 0; // Tracks the current batch index

  String selectedCommodity = 'All';
  List<String> commodityOptions = ['All'];

  String selectedMarket = 'All';
  List<String> marketOptions = ['All'];

  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true; // Keep state alive for performance

  @override
  void initState() {
    super.initState();
    fetchMandiRates();

    // Debounce search to prevent excessive filtering
    searchController.addListener(() {
      _debounceFilter();
    });

    // Add scroll listener for lazy loading more items
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          displayedData.length < filteredData.length) {
        loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Debounce timer for search
  Timer? _debounce;
  void _debounceFilter() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      filterData();
    });
  }

  Future<void> fetchMandiRates() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.post(Uri.parse('${KD.api}/admin/fetch_mandi_rates'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mandiData = data['results'];

          // Populate unique commodity options
          Set<String> uniqueCommodities = {};
          for (var record in mandiData) {
            if (record['Commodity'] != null) {
              uniqueCommodities.add(record['Commodity'].toString());
            }
          }
          commodityOptions = ['All'] + uniqueCommodities.toList()
            ..sort();

          // Populate unique market options
          Set<String> uniqueMarkets = {};
          for (var record in mandiData) {
            if (record['Market'] != null) {
              uniqueMarkets.add(record['Market'].toString());
            }
          }
          marketOptions = ['All'] + uniqueMarkets.toList()
            ..sort();

          isLoading = false;
        });
        filterData();
      } else {
        print("Failed to fetch mandi rates: ${response.statusCode}".tr());
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching mandi rates: $e".tr());
      setState(() {
        isLoading = false;
        mandiData = [];
        filteredData = [];
        displayedData = [];
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

      // Reset displayed data and load initial batch
      currentIndex = 0;
      displayedData = filteredData.take(batchSize).toList();
      currentIndex = displayedData.length;
    });
  }

  void loadMoreData() {
    setState(() {
      isLoadingMore = true;
    });

    // Simulate loading delay (optional, for UX)
    Future.delayed(Duration(milliseconds: 25), () {
      setState(() {
        final nextBatch =
            filteredData.skip(currentIndex).take(batchSize).toList();
        displayedData.addAll(nextBatch);
        currentIndex += nextBatch.length;
        isLoadingMore = false;
      });
    });
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mandi Rates".tr(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
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
                      prefixIcon: Icon(Icons.search, color: Color(0xFF00AD83)),
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
                    tooltip: "Open Filters".tr(),
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // --- Mandi Rates List ---
            isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF00AD83)))
                : filteredData.isEmpty
                    ? Center(
                        child:
                            Text("No data available for the selected filters.".tr()))
                    : Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              displayedData.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the bottom when loading more
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          value: record['Modal_Price'] ?? 'N/A',
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