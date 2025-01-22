import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MandiRatesPage extends StatefulWidget {
  @override
  _MandiRatesPageState createState() => _MandiRatesPageState();
}

class _MandiRatesPageState extends State<MandiRatesPage> {
  final String apiUrl =
      'https://api.data.gov.in/resource/35985678-0d79-46b4-9ed6-6f13308a1d24'
      '?api-key=579b464db66ec23bdd00000193cd44da4f644b886d3a756d44d8bbfe'
      '&format=json&filters%5BState.keyword%5D=Karnataka'
      '&filters%5BArrival_Date%5D=04%2F12%2F2024&limit=10000'
      '&filters%5BDistrict.keyword%5D=Kalburgi';

  List<dynamic> mandiData = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;
  String selectedCommodity = 'All';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMandiRates();
  }

  Future<void> fetchMandiRates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mandiData = data['records'];
          filteredData = mandiData;
          isLoading = false;
        });
      } else {
        print("Failed to fetch mandi rates: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void filterData() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = mandiData.where((record) {
        final market = (record['Market'] ?? '').toLowerCase();
        final commodity = (record['Commodity'] ?? '').toLowerCase();
        bool matchesQuery = market.contains(query) || commodity.contains(query);

        if (selectedCommodity == 'All') {
          return matchesQuery;
        } else {
          return matchesQuery && commodity == selectedCommodity.toLowerCase();
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mandi Rates"),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search and Filter Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search markets or commodities",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.green.shade800),
                      ),
                    ),
                    onChanged: (value) {
                      filterData();
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCommodity,
                  dropdownColor: Colors.green.shade50,
                  style: TextStyle(color: Colors.green.shade800),
                  items: ['All', 'Wheat', 'Rice', 'Maize', 'Cotton']
                      .map((commodity) => DropdownMenuItem(
                    value: commodity,
                    child: Text(commodity),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCommodity = value!;
                      filterData();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Mandi Rates List
            isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredData.isEmpty
                ? Center(child: Text("No data available"))
                : Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final record = filteredData[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                record['Market'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  record['Commodity'] ?? 'N/A',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor:
                                Colors.green.shade700,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              PriceTile(
                                label: "Min Price",
                                value: record['Min_Price'] ?? 'N/A',
                                color: Colors.green.shade800,
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

void main() {
  runApp(MaterialApp(
    home: MandiRatesPage(),
  ));
}
