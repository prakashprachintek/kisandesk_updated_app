import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/laborers/Labour_Booking.dart';
import 'package:mainproject1/views/laborers/Labour_orders.dart';
import 'dart:convert';
import '../services/user_session.dart';
import '../services/api_config.dart';

class LabourrequestNew extends StatefulWidget {
  const LabourrequestNew({Key? key}) : super(key: key);

  @override
  _LabourRequestPageState createState() => _LabourRequestPageState();
}

class _LabourRequestPageState extends State<LabourrequestNew> {
  final TextEditingController _workDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _fromDate;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;
  bool hasSubmitted = false;

  final Color _primaryColor = const Color.fromARGB(255, 29, 108, 92);
  final Color _accentColor = const Color.fromARGB(255, 29, 108, 92);

  @override
  void dispose() {
    _workDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitLabourRequest() async {
    setState(() {
      hasSubmitted = true;
    });

    bool isValid = _formKey.currentState!.validate();
    if (!(_isMaleSelected || _isFemaleSelected)) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Please select at least one labour type"))),
      );
    }
    if (_fromDate == null) {
      isValid = false;
    }
    if (!isValid) return;

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
        _showSuccessDialogAndRedirect();
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr("Server error, please try again later")),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Network error, please check your connection"))),
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
              Text(tr('Success'), style: TextStyle(color: _primaryColor)),
            ],
          ),
          content: Text(tr('Labour Request Initiated Successfully')),
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

  void _resetForm() {
    setState(() {
      _workDescriptionController.clear();
      _fromDate = null;
      _isMaleSelected = false;
      _isFemaleSelected = false;
      hasSubmitted = false;
    });
    _formKey.currentState!.reset();
  }

  Future<void> _pickDate() async {
    DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (hasSubmitted) {
          _formKey.currentState!.validate();
        }
      });
    }
  }

  Widget _buildLabourForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
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
                        tr("Create Labour Request"),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      tr("Select Labour Type"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildGenderSelection(
                          tr("Male"),
                          _isMaleSelected,
                          (value) {
                            setState(() {
                              _isMaleSelected = value!;
                              if (hasSubmitted) {
                                _formKey.currentState!.validate();
                              }
                            });
                          },
                          'assets/Male.png',
                        ),
                        _buildGenderSelection(
                          tr("Female"),
                          _isFemaleSelected,
                          (value) {
                            setState(() {
                              _isFemaleSelected = value!;
                              if (hasSubmitted) {
                                _formKey.currentState!.validate();
                              }
                            });
                          },
                          'assets/Female.png',
                        ),
                      ],
                    ),
                    if (hasSubmitted && !_isMaleSelected && !_isFemaleSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          tr("Please select at least one labour type"),
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 30),
                    Text(
                      tr("Work Details"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDatePickerButton(),
                    if (hasSubmitted && _fromDate == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          tr("Please select a work date"),
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildWorkDescriptionField(),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitLabourRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                        ),
                        child: Text(
                          tr("Submit Request"),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            color: isSelected
                ? _primaryColor
                : (hasSubmitted && !_isMaleSelected && !_isFemaleSelected)
                    ? Colors.red
                    : Colors.transparent,
            width: (hasSubmitted && !_isMaleSelected && !_isFemaleSelected) ? 2 : (isSelected ? 2 : 1),
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
            Image.asset(
              imagePath,
              color: isSelected ? Colors.white : Colors.black87,
              width: 48,
              height: 48,
            ),
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
            : tr("Select Work Date"),
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        side: hasSubmitted && _fromDate == null
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
    );
  }

  Widget _buildWorkDescriptionField() {
    return TextFormField(
      controller: _workDescriptionController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: tr('Work Description'),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        alignLabelWithHint: true,
      ),
      validator: (value) => value == null || value.trim().isEmpty ? tr("Please enter a work description") : null,
      onChanged: (value) {
        if (hasSubmitted) {
          _formKey.currentState!.validate();
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("Labour Request"),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: _buildLabourForm(),
    );
  }
}