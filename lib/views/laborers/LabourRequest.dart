import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

// Ensure this file exists and has your "Add Me As Labour" functionality.
import '../other/AddMeAsLabour_page.dart';

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
  final TextEditingController _workDescriptionController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

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

  // Submits the labour request to Firebase
  Future<void> _submitLabourRequest() async {
    if (!_validateForm()) return;

    Map<String, dynamic> request = {
      'work': _workDescriptionController.text,
      'work_date_from': _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '',
      'work_date_to': _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '',
      'total_male_labours': _isMaleSelected ? _maleLabourController.text : '0',
      'total_female_labours': _isFemaleSelected ? _femaleLabourController.text : '0',
      'farmer_id': widget.userData['farmer_id'] ?? '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final DatabaseReference requestsRef = FirebaseDatabase.instance.ref("labourRequests");

    try {
      await requestsRef.push().set(request);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Labour request submitted successfully!")),
      );
      _resetForm();
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
    if (_isMaleSelected && _maleLabourController.text.isEmpty) {
      _showError("Please enter the number of male labours.");
      return false;
    }
    if (_isFemaleSelected && _femaleLabourController.text.isEmpty) {
      _showError("Please enter the number of female labours.");
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
                        Text("From Date: ${_fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : 'Not selected'}",
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
                        Text("To Date: ${_toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : 'Not selected'}",
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

  // ----------------- Labour Dashboard Tab -----------------
  Widget _buildLabourDashboardTab() {
    final DatabaseReference requestsRef =
    FirebaseDatabase.instance.ref("labourRequests");
    return StreamBuilder(
      stream: requestsRef.onValue,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Map<dynamic, dynamic>? data = snapshot.data.snapshot.value as Map?;
        if (data == null) {
          return Center(child: Text("No Labour Requests Available"));
        }
        List<Map<String, dynamic>> requests =
        data.values.map((e) => Map<String, dynamic>.from(e)).toList();

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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          AddMeAsLabourPage(userData: widget.userData, phoneNumber: widget.phoneNumber),
          _buildLabourDashboardTab(),
        ],
      ),
    );
  }
}
