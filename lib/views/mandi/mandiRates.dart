import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MandiRatesPage extends StatefulWidget {
  @override
  _MandiRatesPageState createState() => _MandiRatesPageState();
}

class _MandiRatesPageState extends State<MandiRatesPage> {
  final String apiUrl = 'http://13.233.103.50/api/admin/fetch_mandi_rates';

  List<dynamic> mandiData = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;

  String selectedCommodity = 'All';
  List<String> commodityOptions = ['All'];

  String selectedMarket = 'All';
  List<String> marketOptions = ['All'];
  //TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMandiRates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchMandiRates() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
      );

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
          filterData();
          isLoading = false;
        });
      } else {
        print("Failed to fetch mandi rates: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
        mandiData = [];
        filteredData = [];
      });
    }
  }

  void filterData() {
    //String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = mandiData.where((record) {
        final commodity = (record['Commodity'] ?? "").toLowerCase();
        final market = (record['Market'] ?? "").toLowerCase();

        bool matchesCommodity = selectedCommodity == 'All' ||
            commodity == selectedCommodity.toLowerCase();

        bool matchesMarket =
            selectedMarket == 'All' || market == selectedMarket.toLowerCase();

        return matchesCommodity && matchesMarket;
      }).toList();
    });
  }
  /*if (selectedCommodity == 'All') {
        filteredData = mandiData;
      } else {
        filteredData = mandiData.where((record) {
          final commodity = (record['Commodity'] ?? '').toLowerCase();
          return commodity == selectedCommodity.toLowerCase();
        }).toList();
      }
    });
  }
    filteredData = mandiData.where((record) {
        //final market = (record['Market'] ?? '').toLowerCase();
        final commodity = (record['Commodity'] ?? '').toLowerCase();
        //bool matchesQuery = market.contains(query) || commodity.contains(query);

        if (selectedCommodity == 'All') {
          return true;
        } else {
          return commodity == selectedCommodity.toLowerCase();
        }
      }).toList();
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test dev"),
        centerTitle: true,
        backgroundColor: Color(0xFF00AD83),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Search and Filter Section
          children: [
            /*Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search markets or commodities",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 249, 253, 252)),
                      ),
                    ),
                    onChanged: (value) {
                      filterData();
                    },
                  ),
                ),

                SizedBox(width: 10),*/
            Row(
              children: [
                Expanded(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //children: [
                  //Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Commodity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    value: selectedCommodity,
                    dropdownColor: const Color.fromARGB(255, 234, 238, 234),
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    items: commodityOptions
                        .map((commodity) => DropdownMenuItem(
                              value: commodity,
                              child: Flexible(
                                child: Text(
                                  commodity,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCommodity = value!;
                        filterData();
                      });
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Market',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    value: selectedMarket,
                    dropdownColor: const Color.fromARGB(255, 234, 238, 234),
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    items: marketOptions
                        .map((market) => DropdownMenuItem(
                              value: market,
                              child: Flexible(
                                child: Text(
                                  market,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMarket = value!;
                        filterData();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            /*Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(

                  value: selectedCommodity,
                  dropdownColor: const Color.fromARGB(255, 234, 238, 234),
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  items: commodityOptions
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
                  }
                  /*[
                  'All',
                  'Arhar (Tur/Red Gram)(Whole)',
                  'Jowar(Sorghum)',
                  'Beans',
                  'Brinjal',
                  'Bhindi(Ladies Finger)',
                  'onion',
                  'soyabean',
                  'Sesamum(Sesame,Gingelly,Til)',
                  'Sunflower',
                  'tomato',
                  'Wheat',
                  'Rice',
                  'Maize',
                  'Cotton'
                ]
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
                },*/
                  ),
            ),*/

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
                              color: const Color.fromARGB(255, 255, 255, 255),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      //mainAxisAlignment:
                                      //MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            record['District'] ?? 'N/A',
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
                                          child: Chip(
                                            label: Text(
                                              record['Commodity'] ?? 'N/A',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            backgroundColor: Color(0xFF00AD83),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
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

void main() {
  runApp(MaterialApp(
    home: MandiRatesPage(),
  ));
}
