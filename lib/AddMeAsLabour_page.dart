import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddMeAsLabourPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  AddMeAsLabourPage({required this.phoneNumber,required this.userData});

  @override
  _AddMeAsLabourPageState createState() => _AddMeAsLabourPageState();
}

class _AddMeAsLabourPageState extends State<AddMeAsLabourPage> {
  final List<String> skills = ['Driver', 'Farmer', 'Mestri', 'Painter', 'Carpenter', 'Plumber'];
  final List<String> workModes = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  String? _selectedSkill;
  String? _selectedWorkMode;
  final TextEditingController _descriptionController = TextEditingController();

  // Function to call the API
  Future<void> _submitLabourRequest() async {
    final String userId = widget.userData['farmer_id'];  // Example user ID, replace with dynamic data if needed
    final List<String> labourSkills = [_selectedSkill ?? ''];  // Ensure a valid skill is selected
    final String labourMode = _selectedWorkMode ?? 'Daily'; // Ensure a valid work mode is selected

    // Prepare the data to be sent
    final Map<String, dynamic> data = {
      'userId': userId,
      'isLabour': 'true',
      'labourMode': labourMode.toLowerCase(),
      'labourSkills': labourSkills.map((e) => e.toLowerCase()).toList(),
    };

    // Send the API request
    try {
      final response = await http.post(
        Uri.parse('http://3.110.121.159/api/user/mark_as_labour'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          // Optionally show success message and handle the response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have been marked as a labourer successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to mark as labourer.')),
          );
        }
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (error) {
      // Handle any error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Skill:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButtonFormField<String>(
                value: _selectedSkill,
                items: skills.map((skill) {
                  return DropdownMenuItem(
                    value: skill,
                    child: Text(skill),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSkill = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.green.shade50,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Select Work Mode:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButtonFormField<String>(
                value: _selectedWorkMode,
                items: workModes.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWorkMode = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.green.shade50,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
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
                  onPressed: _submitLabourRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00AD83),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
