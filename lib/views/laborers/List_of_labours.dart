import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/laborers/labour_details_page.dart';
import '../services/api_config.dart';

class ListOfLaboursPage extends StatefulWidget {
  const ListOfLaboursPage({Key? key}) : super(key: key);

  @override
  State<ListOfLaboursPage> createState() => _ListOfLaboursPageState();
}

class _ListOfLaboursPageState extends State<ListOfLaboursPage> {
  String selectedCategory = "All";
  String selectedSubCategory = "";

  bool filterNearby = false;
  String genderFilter = "All";

  List<dynamic> labours = [];
  bool isLoading = true;

  final Map<String, List<String>> subCategories = {
    "All": [],
    "Agriculture Labour": [
      "Field Cleaning",
      "Sugarcane Planting",
      "Weeding",
      "Cotton Picking",
      "Vegetable Harvesting",
      "Crop Loading",
      "Sprayer"
    ],
    "Drivers & Opertors": [
      "Tractor Driver",
      "Truck Driver",
      "JCB Operator",
      "Car Driver",
      "Tempo Driver",
      "Water Tanker Driver"
    ],
    "Electrical Wors": [
      "House Wiring",
      "Motor Installation",
      "Pump Repaar",
      "Solar Panel Installation",
      "Electrical Maintenace"
    ],
    "Plumbing Works": [
      "Pipe Fitting",
      "Water Tank Installation",
      "Motor Pipe Setup",
      "Leak Repair",
      "Drip Irrigation Setup"
    ],
    "Painting Work": [
      "Interior Painting",
      "Exterior Painting",
      "Wall Putty Work",
      "Spray Painting"
    ],
    "Construction Labour": [
      "Mason Work",
      "Tile Fitting",
      "Concrete Work",
      "Helper / Coolie"
    ],
    "Cleaning & Maintenance": [
      "House Cleaning",
      "Farm Cleaning",
      "Warehouse Cleaning",
      "Water Tank Cleaning"
    ],
  };

  @override
  void initState() {
    super.initState();
    fetchLabours();
  }

  int _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return 0;

    try {
      final parts = dob.split("-");
      final birthDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      final today = DateTime.now();
      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0;
    }
  }

  Future<void> fetchLabours() async {
    const url = "${KD.api}/user/get_all_users";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"model": "labours", "pincode": "585213"}),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        setState(() {
          labours = data["results"]
              .where((item) => item["is_labour"] == true)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching labours: $e");
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Nearby Labours"),
                      Switch(
                        value: filterNearby,
                        onChanged: (value) {
                          setModalState(() {
                            filterNearby = value;
                          });
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Gender",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("All"),
                        selected: genderFilter == "All",
                        onSelected: (v) {
                          setModalState(() {
                            genderFilter = "All";
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Male"),
                        selected: genderFilter == "male",
                        onSelected: (v) {
                          setModalState(() {
                            genderFilter = "male";
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Female"),
                        selected: genderFilter == "female",
                        onSelected: (v) {
                          setModalState(() {
                            genderFilter = "female";
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D67),
                      ),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filters"),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabourList() {
    List filteredLabours = labours.where((labour) {
      if (selectedCategory != "All" &&
          labour["work_category"] != selectedCategory) {
        return false;
      }

      if (selectedSubCategory.isNotEmpty &&
          !(labour["sub_category"] ?? []).contains(selectedSubCategory)) {
        return false;
      }

      if (genderFilter != "All" &&
          (labour["gender"] ?? "").toString().toLowerCase() != genderFilter) {
        return false;
      }

      if (filterNearby && labour["pincode"] != "585213") {
        return false;
      }

      return true;
    }).toList();

    if (filteredLabours.isEmpty) {
      return const Center(child: Text("No labours found"));
    }

    return ListView.builder(
      itemCount: filteredLabours.length,
      itemBuilder: (context, index) {
        final labour = filteredLabours[index];
        final gender = (labour["gender"] ?? "").toString().toLowerCase();
        final age = _calculateAge(labour["dob"]);

        // ✅ MASKING LOGIC HERE
        final phone = (labour["phone"] ?? "").toString();
        final maskedPhone = phone.length >= 10
            ? "${phone.substring(0, 2)}******${phone.substring(phone.length - 2)}"
            : phone;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                Colors.white,
                Color.fromARGB(215, 223, 241, 223),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight, 
                ),
            ),
          
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(
                gender == "female"
                    ? "assets/Female.png"
                    : "assets/Male.png",
              ),
            ),

            title: Text(
              labour["full_name"] ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (age > 0)
                  Text("$age years",
                      style: const TextStyle(fontSize: 13)),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.work,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        labour["work_category"] ?? "",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ✅ MASKED PHONE DISPLAY
                Text(
                  maskedPhone,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            isThreeLine: true,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LabourDetailsPage(labour: labour),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    final bool isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
            selectedSubCategory = "";
          });
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2E7D67)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tr(category),
            style: TextStyle(
              color:
                  isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryChip(String subCategory) {
    final bool isSelected = selectedSubCategory == subCategory;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSubCategory = subCategory;
          });
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.black87
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
     tr( subCategory),
            style: TextStyle(
              color:
                  isSelected ? Colors.white : Colors.black87,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        //backgroundColor: const Color(0xFF2E7D67),
        elevation: 0,
        title: Text(
          "List_of_labours",
          style:
              TextStyle(fontWeight: FontWeight.w600),
        ).tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: subCategories.keys
                          .map((category) =>
                              _buildCategoryChip(category))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (subCategories[selectedCategory]!.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: subCategories[selectedCategory]!
                            .map((sub) =>
                                _buildSubCategoryChip(sub))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildLabourList()),
                ],
              ),
            ),
    );
  }
}