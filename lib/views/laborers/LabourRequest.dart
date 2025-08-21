import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/laborers/Requestdetails.dart';
import 'dart:convert';
import '../services/user_session.dart';
import '../services/api_config.dart';

class LabourRequestPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  const LabourRequestPage({
    Key? key,
    required this.userData,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _LabourRequestPageState createState() => _LabourRequestPageState();
}

class _LabourRequestPageState extends State<LabourRequestPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _maleLabourController = TextEditingController();
  final TextEditingController _femaleLabourController = TextEditingController();
  final TextEditingController _workDescriptionController =
      TextEditingController();
  DateTime? _fromDate;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maleLabourController.dispose();
    _femaleLabourController.dispose();
    _workDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitLabourRequest() async {
    if (!_validateForm()) return;

    // Determine labour type based on UI selection
    String labourType = '';
    if (_isMaleSelected && !_isFemaleSelected) {
      labourType = 'male';
    } else if (!_isMaleSelected && _isFemaleSelected) {
      labourType = 'female';
    } else if (_isMaleSelected && _isFemaleSelected) {
      labourType = 'both';
    }

    Map<String, dynamic> requestBody = {
      'farmer_id': widget.userData['farmer_id']?.toString() ??
          UserSession.userId.toString(),
      'labour_type': labourType,
      'work_date_from':
          _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '',
      'work': _workDescriptionController.text,
    };

    final Uri apiUrl = Uri.parse('${KD.api}/admin/create_labours_request');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Labour request submitted successfully!")),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to submit request: ${response.statusCode} ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit request: $e")),
      );
    }
  }

  bool _validateForm() {
    if (!_isMaleSelected && !_isFemaleSelected) {
      _showError("Please select at least one labour type.");
      return false;
    }
    if (_fromDate == null) {
      _showError("Please select a date.");
      return false;
    }
    /*
    if (_workDescriptionController.text.isEmpty) {
      _showError("Please enter a work description.");
      return false;
    }
    */
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _resetForm() {
    setState(() {
      _maleLabourController.clear();
      _femaleLabourController.clear();
      _workDescriptionController.clear();
      _fromDate = null;
      _isMaleSelected = false;
      _isFemaleSelected = false;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Widget _buildLabourFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Labour Request",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Labour Type:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isMaleSelected,
                          onChanged: (value) {
                            setState(() {
                              _isMaleSelected = value ?? false;
                            });
                          },
                        ),
                        // const Icon(Icons.male, color: Colors.black),
                        // const SizedBox(width: 2),
                        const Text("🚹 Male", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isFemaleSelected,
                          onChanged: (value) {
                            setState(() {
                              _isFemaleSelected = value ?? false;
                            });
                          },
                        ),
                        // const Icon(Icons.female, color: Colors.black),
                        // const SizedBox(width: 2),
                        const Text("🚺 Female", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Work Details:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today,
                    size: 20, color: Colors.white),
                label: Text(
                  _fromDate != null
                      ? DateFormat('yyyy-MM-dd').format(_fromDate!)
                      : "Select Work Date",
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _workDescriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    //child: Icon(Icons.description, color: Color(0xFF2E7D32)),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitLabourRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Submit Request",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //main page with tabs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Labour Management",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        // backgroundColor: Colors.transparent,
        /*
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF66BB6A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        */
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Labour Form'),
            Tab(text: 'Dashboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLabourFormTab(),
          _buildLabourDashboardTab(),
        ],
      ),
    );
  }

  // --- Your _buildLabourDashboardTab and other methods here ---

  // Fetches labour requests from your API
  Future<List<Map<String, dynamic>>> _fetchLabourRequests() async {
    final Uri apiUrl = Uri.parse('${KD.api}/admin/get_labours_request');
    Map<String, String> body = {
      'farmer_id': widget.userData['farmer_id']?.toString() ??
          UserSession.userId.toString(),
    };
    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success' && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception(
            "Failed to load labour requests: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching labour requests: $e");
      throw Exception("Failed to load labour requests: $e");
    }
  }

  Widget _buildLabourDashboardTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchLabourRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Labour Requests Available"));
        }

        List<Map<String, dynamic>> requests = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final item = requests[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestDetailsPage(requestData: item),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['work']?.toString() ?? 'No Work Description',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 16),
                          SizedBox(width: 8),
                          Text(
                              'From: ${item['work_date_from']?.toString() ?? 'N/A'}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16),
                          SizedBox(width: 8),
                          Text(
                              'Gender: ${item['labour_type']?.toString() ?? 'N/A'}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16),
                          SizedBox(width: 8),
                          //Text('To: ${item['work_date_to']?.toString() ?? 'N/A'}'),
                          Text(
                              'Status: ${item['status']?.toString() ?? 'N/A'}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}