import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/laborers/Labour_orders.dart';
import 'dart:convert';
import '../services/user_session.dart';
import '../services/api_config.dart';

class LabourrequestNew extends StatefulWidget {
  //final Map<String, dynamic> userData;
 //final String phoneNumber;

  const LabourrequestNew({
    Key? key,
    //required this.userData,
    //required this.phoneNumber,
  }) : super(key: key);

  @override
  _LabourRequestPageState createState() => _LabourRequestPageState();
}

class _LabourRequestPageState extends State<LabourrequestNew> {
  final TextEditingController _workDescriptionController = TextEditingController();
  DateTime? _fromDate;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  @override
  void dispose() {
    _workDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitLabourRequest() async {
    if (!_validateForm()) return;

    String labourType = '';
    if (_isMaleSelected && !_isFemaleSelected) {
      labourType = 'male';
    } else if (!_isMaleSelected && _isFemaleSelected) {
      labourType = 'female';
    } else if (_isMaleSelected && _isFemaleSelected) {
      labourType = 'both';
    }

    Map<String, dynamic> requestBody = {
      'farmer_id': UserSession.userId?.toString() ?? UserSession.userId.toString(),
      'labour_type': labourType,
      'work_date_from': _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '',
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
          const SnackBar(content: Text("Labour request submitted successfully!")),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit request: ${response.statusCode} ${response.body}")),
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
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _resetForm() {
    setState(() {
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

  Widget _buildLabourForm() {
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Labour Type:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
                        const Text("🚺 Female", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Work Details:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 20, color: Colors.white),
                label: Text(
                  _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : "Select Work Date",
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _workDescriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "Submit Request",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Labour Request", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: _buildLabourForm(),
    );
  }
}