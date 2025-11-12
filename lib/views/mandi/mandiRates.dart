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
  bool isLoadingList = true;     // Only for list
  bool isFetching = false;       // Background API
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
    await Hive.initFlutter();
    cacheBox = await Hive.openBox('mandi_rates_box');
    await _loadFromCache(); // Load cache first
    _fetchMandiRatesInBackground(); // Then fetch fresh
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    cacheBox.close();
    _debounce?.cancel();
    super.dispose();
  }

  Timer? _debounce;
  void _debounceFilter() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), filterData);
  }

  // Helper: Safely add 'All' only once
  List<String> _withAll(List<String> items) {
    final set = items.toSet()..remove('All');
    return ['All', ...set.toList()..sort()];
  }

  // Load from cache immediately
  Future<void> _loadFromCache() async {
    try {
      final cachedData = cacheBox.get('data');
      final cachedCommodities = cacheBox.get('commodities');
      final cachedMarkets = cacheBox.get('markets');
      final cachedTimestamp = cacheBox.get('last_updated');

      if (cachedData is List && cachedData.isNotEmpty) {
        setState(() {
          mandiData = cachedData;
          commodityOptions = _withAll(cachedCommodities?.cast<String>() ?? []);
          marketOptions = _withAll(cachedMarkets?.cast<String>() ?? []);
          lastUpdated = cachedTimestamp;
          isLoadingList = false;
          isOffline = false;
        });
        filterData();
      } else {
        setState(() {
          isLoadingList = true;
        });
      }
    } catch (e) {
      print("Cache error: $e");
      setState(() {
        isLoadingList = true;
      });
    }
  }

  // Background fetch
  void _fetchMandiRatesInBackground() async {
    if (isFetching) return;
    setState(() => isFetching = true);

    for (int i = 0; i <= 2; i++) {
      try {
        final response = await http
            .post(Uri.parse(apiUrl))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          if (results.isEmpty) break;

          final Set<String> comms = {};
          final Set<String> markets = {};
          for (var r in results) {
            if (r['Commodity'] != null) comms.add(r['Commodity'].toString());
            if (r['Market'] != null) markets.add(r['Market'].toString());
          }

          setState(() {
            mandiData = results;
            commodityOptions = _withAll(comms.toList());
            marketOptions = _withAll(markets.toList());
            lastUpdated = DateTime.now().toString();
            isLoadingList = false;
            isOffline = false;
            isFetching = false;
          });

          // Save cache
          await cacheBox.put('data', results);
          await cacheBox.put('commodities', commodityOptions.sublist(1));
          await cacheBox.put('markets', marketOptions.sublist(1));
          await cacheBox.put('last_updated', lastUpdated);

          filterData();
          return;
        }
      } catch (e) {
        if (i == 2) {
          setState(() {
            isOffline = true;
            isFetching = false;
            if (mandiData.isEmpty) isLoadingList = false;
          });
        }
        await Future.delayed(Duration(seconds: 1 << i));
      }
    }
  }

  void filterData() {
    final query = searchController.text.toLowerCase().trim();
    final commLower = selectedCommodity.toLowerCase();
    final marketLower = selectedMarket.toLowerCase();

    final filtered = mandiData.where((r) {
      final c = (r['Commodity'] ?? '').toString().toLowerCase();
      final m = (r['Market'] ?? '').toString().toLowerCase();
      final d = (r['District'] ?? '').toString().toLowerCase();

      final matchComm = selectedCommodity == 'All' || c == commLower;
      final matchMarket = selectedMarket == 'All' || m == marketLower;
      final matchSearch = query.isEmpty || c.contains(query) || m.contains(query) || d.contains(query);

      return matchComm && matchMarket && matchSearch;
    }).toList();

    setState(() {
      filteredData = filtered;
      currentIndex = 0;
      displayedData = filtered.take(batchSize).toList();
      currentIndex = displayedData.length;
    });
  }

  void loadMoreData() {
    setState(() => isLoadingMore = true);
    final next = filteredData.skip(currentIndex).take(batchSize).toList();
    setState(() {
      displayedData.addAll(next);
      currentIndex += next.length;
      isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadFromCache();
    _fetchMandiRatesInBackground();
  }

  void _showFilterBottomSheet() {
    String tempCommodity = selectedCommodity;
    String tempMarket = selectedMarket;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, modalSetState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Filter Options".tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00AD83))),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: tempCommodity,
                  decoration: InputDecoration(labelText: 'Select Commodity'.tr(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  items: commodityOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => modalSetState(() => tempCommodity = v!),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: tempMarket,
                  decoration: InputDecoration(labelText: 'Select Market'.tr(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  items: marketOptions.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => modalSetState(() => tempMarket = v!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCommodity = tempCommodity;
                      selectedMarket = tempMarket;
                    });
                    filterData();
                    Navigator.pop(context);
                  },
                  child: Text("Apply Filters".tr()),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AD83), foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Mandi Rates".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF00AD83),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search market, commodity, or district".tr(),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF00AD83)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00AD83))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00AD83), width: 2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF00AD83), borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterBottomSheet,
                      tooltip: "Open Filters",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              /*
              if (lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    isOffline ? "Showing cached data (Last updated: $lastUpdated).".tr() : "Last updated: $lastUpdated".tr(),
                    style: TextStyle(fontSize: 14, color: isOffline ? Colors.red : Colors.grey[600]),
                  ),
                ),
                */
              const SizedBox(height: 10),
              isLoadingList && mandiData.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AD83)))
                  : filteredData.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              Text("No data available for the selected filters.".tr()),
                              if (isOffline)
                                ElevatedButton(onPressed: _fetchMandiRatesInBackground, child: Text("Retry".tr())),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: displayedData.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == displayedData.length && isLoadingMore) {
                                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Color(0xFF00AD83))));
                              }
                              final r = displayedData[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(child: Text(r['Market'] ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00AD83)), overflow: TextOverflow.ellipsis)),
                                          const SizedBox(width: 8),
                                          Flexible(child: Text(r['Commodity'] ?? 'N/A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(r['District'] ?? 'N/A', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          PriceTile(label: "Min Price", value: r['Min_Price'] ?? 'N/A', color: Colors.black87),
                                          PriceTile(label: "Max Price", value: r['Max_Price'] ?? 'N/A', color: Colors.red.shade700),
                                          PriceTile(label: "Modal Price", value: r['Modal_Price'] ?? 'N/A', color: Colors.orange.shade700),
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
  final String label, value;
  final Color color;
  const PriceTile({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text("₹$value", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      );
}