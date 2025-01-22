import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AddMeAsLabour_page.dart';
import 'DashboardTab_page.dart';

class LabourRequestPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  LabourRequestPage({required this.phoneNumber,required this.userData});

  @override
  _LabourRequestPageState createState() => _LabourRequestPageState();
}

class _LabourRequestPageState extends State<LabourRequestPage> with SingleTickerProviderStateMixin {
  final TextEditingController _maleLabourController = TextEditingController();
  final TextEditingController _femaleLabourController = TextEditingController();
  final TextEditingController _workDescriptionController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Updated to 3 tabs
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

  Future<void> _submitRequest() async {
    if (_validateForm()) {
      final url = Uri.parse('http://3.110.121.159/api/admin/create_labours_request');
      final body = {
        "farmer_id": widget.userData['farmer_id'], // Replace with actual farmer ID
        "work": _workDescriptionController.text,
        "work_date_from": _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '',
        "work_date_to": _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '',
        "total_male_labours": _maleLabourController.text,
        "total_female_labours": _femaleLabourController.text,
      };

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(body),
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Success'),
              content: Text('Labour request created successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetForm();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create labour request: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
      _showError("Please select both from and to dates.");
      return false;
    }
    if (_workDescriptionController.text.isEmpty) {
      _showError("Please enter a work description.");
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isFromDate) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Labour Management'),
        backgroundColor: Color(0xFF00AD83),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Color for the selected tab's text
          unselectedLabelColor: Colors.black54, // Color for unselected tabs' text
          indicatorColor: Colors.white, // Color for the selected tab's underline indicator
          tabs: [
            Tab(text: 'Labour Form'),
            Tab(text: 'Add Me As\nLabour'),
            Tab(text: 'Dashboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLabourFormTab(),
          AddMeAsLabourPage(userData: widget.userData, phoneNumber:widget.phoneNumber,),
          DashboardTab(userData:widget.userData, phoneNumber:widget.phoneNumber,),
        ],
      ),
    );
  }


  Widget _buildLabourFormTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Labour Type:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isMaleSelected,
                        onChanged: (value) {
                          setState(() {
                            _isMaleSelected = value!;
                          });
                        },
                      ),
                      Text("Male"),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isFemaleSelected,
                        onChanged: (value) {
                          setState(() {
                            _isFemaleSelected = value!;
                          });
                        },
                      ),
                      Text("Female"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maleLabourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Male Labours',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.green.shade50,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _femaleLabourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Female Labours',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.green.shade50,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildDatePickers(),
            SizedBox(height: 16),
            TextField(
              controller: _workDescriptionController,
              decoration: InputDecoration(
                labelText: 'Work Description',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00AD83),
                ),
                child: Text('Submit Request',
                style:TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: 'From Date',
            date: _fromDate,
            onPickDate: () => _pickDate(context, true),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildDatePicker(
            label: 'To Date',
            date: _toDate,
            onPickDate: () => _pickDate(context, false),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({required String label, DateTime? date, required VoidCallback onPickDate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Not Selected'}'),
        ElevatedButton(
          onPressed: onPickDate,
          style: ElevatedButton.styleFrom( backgroundColor: Color(0xFF00AD83)),
          child: Text('Pick $label',
          style: TextStyle(color:Colors.white),),
        ),
      ],
    );
  }
}
