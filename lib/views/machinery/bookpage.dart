import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/api_config.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String? selectedMachinery;
  String? selectedWorkType;
  String? bookingDate;
  final TextEditingController areaController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> machineryList = [
    'Tractor 🚜',
    'Harvester',
    'Rotavator',
    'JCB'
  ];
  final List<String> workTypes = [
    'Ploughing',
    'Harvesting',
    'Lifting',
    'Land Leveling'
  ];

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
    );

    if (picked != null) {
      setState(() {
        bookingDate = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  void _submitBooking() async {
    if (selectedMachinery != null &&
        selectedWorkType != null &&
        areaController.text.isNotEmpty &&
        bookingDate != null &&
        descriptionController.text.isNotEmpty) {
      final uri = Uri.parse(
          "${KD.api}/app/book_machinary"); // Replace with your actual API URL

      final payload = {
        "farmer_id": "672c7e4f3dd0774ec0b421a1", // Or get dynamically if needed
        "machineryType": selectedMachinery!,
        "workDate": bookingDate!,
        "workType": selectedWorkType!,
        "workInQuantity": areaController.text,
        "description": descriptionController.text,
      };

      try {
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        final responseData = jsonDecode(res.body);

        if (responseData["status"] == "success") {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Booking Successful"),
              content: Text(responseData["message"]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text("OK"))
              ],
            ),
          );
          // Optionally clear form
          setState(() {
            selectedMachinery = null;
            selectedWorkType = null;
            areaController.clear();
            bookingDate = null;
            descriptionController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed: ${responseData["message"]}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Machinery",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Machinery"),
              value: selectedMachinery,
              items: machineryList.map((machine) {
                return DropdownMenuItem(value: machine, child: Text(machine));
              }).toList(),
              onChanged: (value) => setState(() => selectedMachinery = value),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Work Type"),
              value: selectedWorkType,
              items: workTypes.map((work) {
                return DropdownMenuItem(value: work, child: Text(work));
              }).toList(),
              onChanged: (value) => setState(() => selectedWorkType = value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "No. of Acres / Hours"),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: "Booking Date"),
                child: Text(bookingDate ?? "Select a date"),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description / Notes"),
              maxLines: 3,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submitBooking,
              icon: Icon(Icons.send),
              label: Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
