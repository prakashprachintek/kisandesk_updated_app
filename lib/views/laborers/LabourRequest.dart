import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For encoding and decoding JSON

// Ensure this file exists and has your "Add Me As Labour" functionality.
import '../other/AddMeAsLabour_page.dart';
import '../other/user_session.dart';
import '../widgets/api_config.dart';

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

  // Controllers for Labour Form
  final TextEditingController _maleLabourController = TextEditingController();
  final TextEditingController _femaleLabourController = TextEditingController();
  final TextEditingController _workDescriptionController =
      TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  // Define your API base URL
  // UPDATED: Replaced with the new API base URL

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maleLabourController.dispose();
    _femaleLabourController.dispose();
    _workDescriptionController.dispose();
    super.dispose();
  }

  // Submits the labour request to your API
  Future<void> _submitLabourRequest() async {
    if (!_validateForm()) return;

    Map<String, dynamic> requestBody = {
      'work': _workDescriptionController.text,
      'work_date_from':
          _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '',
      'work_date_to':
          _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '',
      'total_male_labours': _isMaleSelected
          ? int.tryParse(_maleLabourController.text) ?? 0
          : 0, // Parse to int
      'total_female_labours': _isFemaleSelected
          ? int.tryParse(_femaleLabourController.text) ?? 0
          : 0, // Parse to int
      'userId': UserSession.userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // UPDATED: Specific endpoint for creating labour requests
    final Uri apiUrl = Uri.parse('${KD.api}/admin/create_labour_request');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle successful response from your API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Labour request submitted successfully!")),
        );
        _resetForm();
      } else {
        // Handle error response from your API
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
    if (_isMaleSelected &&
        (_maleLabourController.text.isEmpty ||
            int.tryParse(_maleLabourController.text) == null)) {
      _showError("Please enter a valid number for male labours.");
      return false;
    }
    if (_isFemaleSelected &&
        (_femaleLabourController.text.isEmpty ||
            int.tryParse(_femaleLabourController.text) == null)) {
      _showError("Please enter a valid number for female labours.");
      return false;
    }
    if (_fromDate == null || _toDate == null) {
      _showError("Please select both start and end dates.");
      return false;
    }
    if (_workDescriptionController.text.isEmpty) {
      _showError("Please enter a work description.");
      return false;
    }
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
      _toDate = null;
      _isMaleSelected = false;
      _isFemaleSelected = false;
    });
  }

  Future<void> _pickDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  // ----------------- Labour Form Tab -----------------
  Widget _buildLabourFormTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Labour Request",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text("Select Labour Type:",
                  style: TextStyle(fontSize: 16, color: Colors.black87)),
              Row(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isMaleSelected,
                        onChanged: (value) {
                          setState(() {
                            _isMaleSelected = value ?? false;
                          });
                        },
                      ),
                      Icon(Icons.male, color: Colors.black),
                      SizedBox(width: 4),
                      Text("Male", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _isFemaleSelected,
                        onChanged: (value) {
                          setState(() {
                            _isFemaleSelected = value ?? false;
                          });
                        },
                      ),
                      Icon(Icons.female, color: Colors.black),
                      SizedBox(width: 4),
                      Text("Female", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              if (_isMaleSelected)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: _maleLabourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of Male Labours',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              SizedBox(height: 16),
              if (_isFemaleSelected)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: _femaleLabourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of Female Labours',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "From Date: ${_fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : 'Not selected'}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _pickDate(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Select From Date"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "To Date: ${_toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : 'Not selected'}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _pickDate(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Select To Date"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _workDescriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitLabourRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Submit Request",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Fetches labour requests from your API
  Future<List<Map<String, dynamic>>> _fetchLabourRequests() async {
    // This endpoint would be for fetching requests, adjust as per your API
    // Assuming your API has an endpoint like '/labour_requests' or similar for GET requests
    final Uri apiUrl = Uri.parse(
        '$_apiBaseUrl/labour_requests'); // You might need to adjust this GET endpoint
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        // Assuming your API returns a list of requests
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception(
            "Failed to load labour requests: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching labour requests: $e");
      throw Exception("Failed to load labour requests: $e");
    }
  }

  // ----------------- Labour Dashboard Tab -----------------
  Widget _buildLabourDashboardTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchLabourRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No Labour Requests Available"));
        }

        List<Map<String, dynamic>> requests = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final item = requests[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['work'] ?? 'No Work Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('From: ${item['work_date_from'] ?? 'N/A'}'),
                    Text('To: ${item['work_date_to'] ?? 'N/A'}'),
                    Text('Status: ${item['status'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('Male Labour: ${item['total_male_labours'] ?? 0}'),
                    Text('Female Labour: ${item['total_female_labours'] ?? 0}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ----------------- Main Build -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Labour Management",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Labour Form'),
            Tab(text: 'Add Me As Labour'),
            Tab(text: 'Dashboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLabourFormTab(),
          AddMeAsLabourPage(
              userData: widget.userData, phoneNumber: widget.phoneNumber),
          _buildLabourDashboardTab(),
        ],
      ),
    );
  }
}
