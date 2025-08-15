import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_session.dart';
import '../widgets/api_config.dart';
import 'machinery_rent_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

// Field validation errors
Map<String, bool> fieldErrors = {
  'machinery': false,
  'workType': false,
  'area': false,
  'date': false,
  'description': false,
};

class _BookPageState extends State<BookPage> {
  // Dropdown selections
  String? selectedMachinery;
  String? selectedWorkType;
  String? bookingDate;
  String selectedUnit = 'Acres';

  // Controllers
  final TextEditingController areaController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Data lists
  List<Map<String, dynamic>> machineryData = [];
  List<String> workTypeList = [];

  // Loading state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMachineryData(); // Fetch machinery data on init
  }

  // Fetch machinery data from API
  Future<void> fetchMachineryData() async {
    setState(() => isLoading = true);
    try {
      final uri = Uri.parse("${KD.api}/app/get_master_data");
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"type": "machine"}));

      final data = jsonDecode(res.body);
      if (data["status"] == "success") {
        final types = data["results"][0]["machinery_type"] as List;
        setState(() {
          machineryData =
              types.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load machinery data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    setState(() => isLoading = false);
  }

  // Open date picker dialog
  void _pickDate() async {
    DateTime today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2026),
    );

    if (picked != null) {
      setState(() {
        bookingDate = DateFormat('yyyy-MM-dd').format(picked);
        fieldErrors['date'] = false;
      });
    }
  }

  // Validate and submit booking
  void _submitBooking() async {
    //validate fields
    setState(() {
      fieldErrors['machinery'] = selectedMachinery == null;
      fieldErrors['workType'] = selectedWorkType == null;
      fieldErrors['area'] = areaController.text.isEmpty;
      fieldErrors['date'] = bookingDate == null;
      fieldErrors['description'] = descriptionController.text.isEmpty;
    });

    // Show error if any field is invalid
    if (fieldErrors.values.any((e) => e)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // API Payload
    final uri = Uri.parse("${KD.api}/app/book_machinary");
    final payload = {
      "userId": UserSession.userId,
      "machineryType": selectedMachinery!,
      "workDate": bookingDate!,
      "workType": selectedWorkType!,
      "workInQuantity": areaController.text,
      "description": descriptionController.text,
      "village": UserSession.user?['village']
    };

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      final responseData = jsonDecode(res.body);

      //Handle API response
      if (responseData["status"] == "success") {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Booking Successful"),
            content: Text(responseData["message"]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MachineryRentPage()),
                  );
                },
                child: Text("OK"),
              ),
            ],
          ),
        );

        //Reset form
        setState(() {
          selectedMachinery = null;
          selectedWorkType = null;
          workTypeList = [];
          areaController.clear();
          bookingDate = null;
          descriptionController.clear();
          fieldErrors.updateAll((key, value) => false);
        });
      }

      //Error Message
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${responseData["message"]}")));
      }
    }

    //Exceptional Errors
    catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Machinery",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF00AD83),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // ----------------------------
                  // Machinery Dropdown
                  // ----------------------------
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Machinery",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['machinery']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['machinery']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['machinery']!
                                ? Colors.red
                                : Color(0xFF00AD83),
                            width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedMachinery,
                    items:
                        machineryData.map<DropdownMenuItem<String>>((machine) {
                      return DropdownMenuItem<String>(
                        value: machine["name"] as String,
                        child: Text(machine["name"] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMachinery = value;
                        workTypeList = machineryData
                            .firstWhere((m) => m["name"] == value)["work_types"]
                            .cast<String>();
                        selectedWorkType = null;
                        fieldErrors['machinery'] = false;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'This field is required' : null,
                  ),
                  if (fieldErrors['machinery']!)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "This field is required",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 16),

                  // ----------------------------
                  // Work Type Dropdown
                  // ----------------------------
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Work Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['workType']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['workType']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['workType']!
                                ? Colors.red
                                : Color(0xFF00AD83),
                            width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedWorkType,
                    items: workTypeList.map<DropdownMenuItem<String>>((work) {
                      return DropdownMenuItem<String>(
                        value: work,
                        child: Text(work),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      selectedWorkType = value;
                      fieldErrors['workType'] = false;
                    }),
                    validator: (value) =>
                        value == null ? 'This field is required' : null,
                  ),
                  if (fieldErrors['workType']!)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "This field is required",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 16),

                  // ----------------------------
                  // Area/Quantity Input
                  // ----------------------------
                  TextField(
                    controller: areaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "No. of Acres / Hours",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['area']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['area']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: fieldErrors['area']!
                                ? Colors.red
                                : Color(0xFF00AD83),
                            width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      suffix: DropdownButton<String>(
                        value: selectedUnit,
                        underline: SizedBox.shrink(),
                        items: ['Acres', 'Hours'].map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      fieldErrors['area'] = value.isEmpty;
                    }),
                  ),
                  if (fieldErrors['area']!)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "This field is required",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 16),

                  // ----------------------------
                  // Date Picker
                  // ----------------------------
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Booking Date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: fieldErrors['date']!
                                  ? Colors.red
                                  : Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: fieldErrors['date']!
                                  ? Colors.red
                                  : Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: fieldErrors['date']!
                                  ? Colors.red
                                  : Color(0xFF00AD83),
                              width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      child: Text(
                        bookingDate ?? "Select a date",
                        style: TextStyle(
                            color: fieldErrors['date']!
                                ? Colors.red
                                : Colors.black),
                      ),
                    ),
                  ),
                  if (fieldErrors['date']!)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "This field is required",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 16),

                  // ----------------------------
                  // Description TextField
                  // ----------------------------
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description / Notes",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: fieldErrors['description']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: fieldErrors['description']!
                                ? Colors.red
                                : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: fieldErrors['description']!
                                ? Colors.red
                                : Color(0xFF00AD83),
                            width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    maxLines: 3,
                    onChanged: (value) => setState(() {
                      fieldErrors['description'] = value.isEmpty;
                    }),
                  ),
                  if (fieldErrors['description']!)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "This field is required",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 30),

                  // ----------------------------
                  // Submit Button
                  // ----------------------------
                  ElevatedButton.icon(
                    onPressed: _submitBooking,
                    label: Text("Book Machine"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
