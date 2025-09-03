import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/laborers/Labour_Booking.dart';
import 'package:mainproject1/views/laborers/Labour_orders.dart';
import 'dart:convert';
import '../services/user_session.dart';
import '../services/api_config.dart';

class LabourrequestNew extends StatefulWidget {
  const LabourrequestNew({
    Key? key,
  }) : super(key: key);

  @override
  _LabourRequestPageState createState() => _LabourRequestPageState();
}

class _LabourRequestPageState extends State<LabourrequestNew> {
  final TextEditingController _workDescriptionController =
      TextEditingController();
  DateTime? _fromDate;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  final Color _primaryColor = const Color.fromARGB(255, 29, 108, 92); // Original primary color
  final Color _accentColor = const Color.fromARGB(255, 29, 108, 92); // Lighter shade for accents

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
      'work_date_from':
          _fromDate != null ? DateFormat('yyy-MM-dd').format(_fromDate!) : '',
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
        _showSuccessDialogAndRedirect();
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

  void _showSuccessDialogAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: _primaryColor),
              SizedBox(width: 10),
              Text('Success!', style: TextStyle(color: _primaryColor)),
            ],
          ),
          content: Text('Request submitted successfully!'),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LabourRequestOrdersPage()),
      );
    });
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
      firstDate: DateTime.now(),
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
      child: Column(
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Create Labour Request",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Select Labour Type:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildGenderSelection("Male", _isMaleSelected, (value) {
                        setState(() {
                          _isMaleSelected = value!;
                        });
                      }, 'assets/Male.png'),
                      _buildGenderSelection("Female", _isFemaleSelected, (value) {
                        setState(() {
                          _isFemaleSelected = value!;
                        });
                      }, 'assets/Female.png'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Work Details:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  _buildDatePickerButton(),
                  const SizedBox(height: 20),
                  _buildWorkDescriptionField(),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitLabourRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
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
        ],
      ),
    );
  }

  Widget _buildGenderSelection(
      String label, bool isSelected, ValueChanged<bool?> onChanged, String imagePath) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor.withOpacity(0.8) : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, color: isSelected ? Colors.white : Colors.black87,
            width: 48,
            height: 48,
            ),
            //Icon(icon, color: isSelected ? Colors.white : Colors.black87),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerButton() {
    return ElevatedButton.icon(
      onPressed: _pickDate,
      icon: const Icon(Icons.calendar_today, size: 20, color: Colors.white),
      label: Text(
        _fromDate != null
            ? DateFormat('yyyy-MM-dd').format(_fromDate!)
            : "Select Work Date",
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
    );
  }

  Widget _buildWorkDescriptionField() {
    return TextField(
      controller: _workDescriptionController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Work Description',
        labelStyle: TextStyle(color: _primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _accentColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        alignLabelWithHint: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Labour Request",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: _buildLabourForm(),
    );
  }
}