import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/user_session.dart';

class ListMyMachineryPage extends StatefulWidget {
  const ListMyMachineryPage({Key? key}) : super(key: key);

  @override
  State<ListMyMachineryPage> createState() => _ListMyMachineryPageState();
}

class _ListMyMachineryPageState extends State<ListMyMachineryPage> {
  Map<String, dynamic>? selectedMachine;
  List<Map<String, dynamic>> selectedWorkTypes = [];
  final TextEditingController vehicleCtrl = TextEditingController();

  List<Map<String, dynamic>> machineryData = [];
  List<Map<String, dynamic>> workTypePool = [];

  bool isLoading = true;

  final ImagePicker _picker = ImagePicker();
  File? image;

  @override
  void initState() {
    super.initState();
    _fetchMachineryData();
  }

  Future<void> _fetchMachineryData() async {
    try {
      final res = await http.post(
        Uri.parse("${KD.api}/app/get_master_data"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"type": "machine"}),
      );

      final data = jsonDecode(res.body);
      if (data["status"] == "success") {
        machineryData = List<Map<String, dynamic>>.from(
          data["results"][0]["machinery_type"],
        );
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked =
        await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text("Camera".tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text("Gallery".tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _networkImage(String? url,
      {double h = 120, double w = 160}) {
    if (url == null || url.isEmpty) {
      return Container(
        height: h,
        width: w,
        color: Colors.grey.shade200,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        height: h,
        width: w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: Colors.grey.shade200),
      ),
    );
  }

  /// 🔹 WORK TYPE SELECTOR WITH DONE BUTTON
  void _openWorkTypeSelector(bool isKannada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Select_Work_Type".tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // list
                  Expanded(
                    child: ListView.builder(
                      itemCount: workTypePool.length,
                      itemBuilder: (_, i) {
                        final w = workTypePool[i];
                        final name = isKannada
                            ? (w["type_in_kannada"] ??
                                w["type_in_english"])
                            : (w["type_in_english"] ?? w["type"]);

                        final selected =
                            selectedWorkTypes.contains(w);

                        return GestureDetector(
                          onTap: () {
                            setSheet(() {
                              selected
                                  ? selectedWorkTypes.remove(w)
                                  : selectedWorkTypes.add(w);
                            });
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            margin:
                                const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? const Color.fromARGB(
                                        255, 29, 108, 92)
                                    : Colors.grey.shade300,
                                width: selected ? 3 : 1.5,
                              ),
                              color: selected
                                  ? const Color.fromARGB(
                                          255, 29, 108, 92)
                                      .withOpacity(0.08)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                _networkImage(w["image"]),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // DONE BUTTON
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 29, 108, 92),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Done".tr(),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKannada =
        Localizations.localeOf(context).languageCode == 'kn';

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F9),
      appBar: AppBar(
        title: Text(
          "List_My_Machinery".tr(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MACHINERY DROPDOWN
                    DropdownMenu<Map<String, dynamic>>(
                      width:
                          MediaQuery.of(context).size.width - 64,
                      hintText: "Select_Machinery".tr(),
                      inputDecorationTheme: _outlineTheme(),
                      dropdownMenuEntries:
                          machineryData.map((m) {
                        final name = isKannada
                            ? (m["name_in_kannada"] ??
                                m["name_in_english"])
                            : (m["name_in_english"] ?? m["name"]);

                        return DropdownMenuEntry(
                          value: m,
                          label: name,
                          labelWidget: Row(
                            children: [
                              _networkImage(m["image"]),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onSelected: (v) {
                        setState(() {
                          selectedMachine = v;
                          workTypePool =
                              List<Map<String, dynamic>>.from(
                                  v?["work_types"] ?? []);
                          selectedWorkTypes.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // WORK TYPE FIELD
                    GestureDetector(
                      onTap: workTypePool.isEmpty
                          ? null
                          : () =>
                              _openWorkTypeSelector(isKannada),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Work_Type".tr(),
                                style: TextStyle(
                                    color:
                                        Colors.grey.shade600)),
                            const SizedBox(height: 8),
                            selectedWorkTypes.isEmpty
                                ? Text(
                                    "Select_Work_Type".tr(),
                                    style: TextStyle(
                                        color: Colors
                                            .grey.shade500),
                                  )
                                : Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children:
                                        selectedWorkTypes.map((w) {
                                      final name = isKannada
                                          ? (w["type_in_kannada"] ??
                                              w["type_in_english"])
                                          : (w["type_in_english"] ??
                                              w["type"]);
                                      return Chip(
                                        label: Text(
                                          name,
                                          style:
                                              const TextStyle(
                                                  fontSize:
                                                      16),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // VEHICLE NUMBER
                    TextFormField(
                      controller: vehicleCtrl,
                      decoration: InputDecoration(
                        labelText:
                            "Vehicle_Number".tr(),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(width: 2),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            width: 2.5,
                            color: Color.fromARGB(
                                255, 29, 108, 92),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // IMAGE
                    GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: image == null
                            ? Column(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  const Icon(
                                      Icons.camera_alt,
                                      size: 30),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Please_upload_the_image"
                                        .tr(),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                        12),
                                child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                  width:
                                      double.infinity,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecorationTheme _outlineTheme() => InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 2.5,
            color: Color.fromARGB(255, 29, 108, 92),
          ),
        ),
      );
}
