import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_session.dart';
import '../widgets/api_config.dart';
import 'machinery_rent_page.dart';
import 'machneryImages.dart';
import 'worktypeImages.dart';

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
      "full_name": UserSession.user?['full_name'] ?? '',
      "phone": UserSession.user?['phone'] ?? '',
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
                  DropdownMenu<String>(
                    menuHeight: 400, // Replaces menuMaxHeight
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: fieldErrors['machinery']!
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: fieldErrors['machinery']!
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: fieldErrors['machinery']!
                              ? Colors.red
                              : Color(0xFF00AD83),
                          width: 2,
                        ),
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
                    hintText: "Select Machinery",
                    initialSelection: selectedMachinery,
                    dropdownMenuEntries: machineryData
                        .asMap()
                        .entries
                        .map<DropdownMenuEntry<String>>((entry) {
                      final index = entry.key;
                      final machine = entry.value;
                      final machineName = machine["name"] as String;
                      return DropdownMenuEntry<String>(
                        value: machineName,
                        label: machineName, // For accessibility
                        labelWidget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Row(
                                  children: [
                                    MachineryImages.getImageWidget(
                                      machineName,
                                      size: 60,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(12),
                                      showShadow: true,
                                      borderColor:
                                          selectedMachinery == machineName
                                              ? Color(0xFF00AD83)
                                              : Colors.transparent,
                                      borderWidth:
                                          selectedMachinery == machineName
                                              ? 2
                                              : 0,
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        machineName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Add divider except for the last item
                            if (index < machineryData.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.shade400,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onSelected: (value) {
                      setState(() {
                        selectedMachinery = value;
                        workTypeList = machineryData
                            .firstWhere((m) => m["name"] == value)["work_types"]
                            .cast<String>();
                        selectedWorkType = null;
                        fieldErrors['machinery'] = false;
                      });
                    },
                  ),
                  // Subtitle for selected machinery
                  if (selectedMachinery != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 12),
                      child: Text(
                        '${workTypeList.length} work types available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  SizedBox(height: 16),

                  // ----------------------------
                  // Work Type Dropdown
                  // ----------------------------
                  SizedBox(
                    width: double
                        .infinity, // Force full width to match other form fields
                    child: DropdownMenu<String>(
                      menuHeight: 400,
                      inputDecorationTheme: InputDecorationTheme(
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: fieldErrors['workType']!
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: fieldErrors['workType']!
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: fieldErrors['workType']!
                                ? Colors.red
                                : Color(0xFF00AD83),
                            width: 2,
                          ),
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
                      hintText: workTypeList.isEmpty
                          ? "Select machinery first"
                          : "Select Work Type",
                      initialSelection: selectedWorkType,
                      dropdownMenuEntries: workTypeList.isEmpty
                          ? [
                              DropdownMenuEntry<String>(
                                value: '',
                                label: 'Select machinery first',
                                enabled: false, // Non-selectable placeholder
                                labelWidget: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Icon(
                                                  Icons.construction,
                                                  size: 36,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                'Select machinery first',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[600],
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
                            ]
                          : workTypeList
                              .asMap()
                              .entries
                              .map<DropdownMenuEntry<String>>((entry) {
                              final index = entry.key;
                              final workType = entry.value;
                              return DropdownMenuEntry<String>(
                                value: workType,
                                label: workType, // For accessibility
                                labelWidget: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: Row(
                                          children: [
                                            // Image from WorkTypeImages
                                            WorkTypeImages.getImageWidget(
                                              workType,
                                              size: 60,
                                              fit: BoxFit.cover,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              showShadow: true,
                                              borderColor:
                                                  selectedWorkType == workType
                                                      ? Color(0xFF00AD83)
                                                      : Colors.transparent,
                                              borderWidth:
                                                  selectedWorkType == workType
                                                      ? 2
                                                      : 0,
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                workType,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Add divider except for the last item
                                    if (index < workTypeList.length - 1)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade400,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                      onSelected: (value) => setState(() {
                        if (value != '') {
                          // Only update if not the placeholder
                          selectedWorkType = value;
                          fieldErrors['workType'] = false;
                        }
                      }),
                    ),
                  ),
                  // Custom error message for validation
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
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Submit Booking",
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
    );
  }
}