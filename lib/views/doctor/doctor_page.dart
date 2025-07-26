import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/api_config.dart';
import '../doctor/doctor_detailpage.dart';
import 'dart:convert';
import '../doctor/doctor.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];

  String searchQuery = '';
  String selectedDistrict = '';
  String selectedTaluka = '';
  String selectedVillage = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final response = await http.post(
        Uri.parse('${KD.api}/app/fetch_doctors_list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final data = decoded['results'];

        List<Doctor> doctors = List<Doctor>.from(data.map((item)=>Doctor.fromJson(item)));
        
        setState(() {
          allDoctors = doctors;
          filteredDoctors = doctors;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching doctors: $e');
    }
  }

  void applyFilters() {
    setState(() {
      filteredDoctors = allDoctors.where((doctor) {
        final matchesSearch =
            doctor.fullname.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesDistrict =
            selectedDistrict.isEmpty || doctor.district == selectedDistrict;
        final matchesTaluka =
            selectedTaluka.isEmpty || doctor.taluka == selectedTaluka;
        final matchesVillage =
            selectedVillage.isEmpty || doctor.village == selectedVillage;

        return matchesSearch &&
            matchesDistrict &&
            matchesTaluka &&
            matchesVillage;
      }).toList();
    });
  }

  void showFilterDialog() {
    String tempDistrict = selectedDistrict;
    String tempTaluka = selectedTaluka;
    String tempVillage = selectedVillage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Filter Doctors"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("District"),
              value: tempDistrict.isEmpty ? null : tempDistrict,
              items: allDoctors
                  .map((d) => d.district)
                  .toSet()
                  .map((district) => DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      ))
                  .toList(),
              onChanged: (value) {
                tempDistrict = value ?? '';
              },
            ),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Taluka"),
              value: tempTaluka.isEmpty ? null : tempTaluka,
              items: allDoctors
                  .map((d) => d.taluka)
                  .toSet()
                  .map((taluka) => DropdownMenuItem(
                        value: taluka,
                        child: Text(taluka),
                      ))
                  .toList(),
              onChanged: (value) {
                tempTaluka = value ?? '';
              },
            ),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Village"),
              value: tempVillage.isEmpty ? null : tempVillage,
              items: allDoctors
                  .map((d) => d.village)
                  .toSet()
                  .map((village) => DropdownMenuItem(
                        value: village,
                        child: Text(village),
                      ))
                  .toList(),
              onChanged: (value) {
                tempVillage = value ?? '';
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedDistrict = tempDistrict;
                selectedTaluka = tempTaluka;
                selectedVillage = tempVillage;
              });
              applyFilters();
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veterinary Doctors",style: TextStyle(color: Colors.white, fontWeight:FontWeight.w700),),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search by name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            searchQuery = value;
                            applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: showFilterDialog,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredDoctors.isEmpty
                      ? const Center(child: Text("No doctors found."))
                      : ListView.builder(
                          itemCount: filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = filteredDoctors[index];
                            return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 5),
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorDetailPage(doctor: doctor),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/doctor_placeholder.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullname,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${doctor.district}, ${doctor.taluka}",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    ),
  ),
);

                          },
                        ),
                ),
              ],
            ),
    );
  }
}
