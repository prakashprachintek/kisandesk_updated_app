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
  List<Map<String, dynamic>> machineryData = [];
  List<Map<String, dynamic>> workTypePool = [];

  final TextEditingController vehicleCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? image;

  bool isLoading = true;

  bool machineError = false;
  bool workTypeError = false;
  bool vehicleError = false;
  bool imageError = false;

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
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
        imageError = false;
      });
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

  Widget _networkImage(String? url, {double h = 90, double w = 130}) {
    if (url == null || url.isEmpty) {
      return Container(height: h, width: w, color: Colors.grey.shade200);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: h,
        width: w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
      ),
    );
  }

  /// WORK TYPE SELECTOR
  void _openWorkTypeSelector(bool isKannada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  Text("Select_Work_Type".tr(),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: workTypePool.length,
                      itemBuilder: (_, i) {
                        final w = workTypePool[i];
                        final name = isKannada
                            ? (w["type_in_kannada"] ?? w["type_in_english"])
                            : (w["type_in_english"] ?? w["type"]);

                        final selected = selectedWorkTypes.contains(w);

                        return GestureDetector(
                          onTap: () {
                            setSheet(() {
                              selected
                                  ? selectedWorkTypes.remove(w)
                                  : selectedWorkTypes.add(w);
                            });
                            setState(() => workTypeError = false);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? const Color.fromARGB(255, 29, 108, 92)
                                    : Colors.grey.shade300,
                                width: selected ? 3 : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                _networkImage(w["image"]),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 29, 108, 92),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text("Done".tr(),
                          style: const TextStyle(fontSize: 18)),
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

  Future<void> _submit() async {
    setState(() {
      machineError = selectedMachine == null;
      workTypeError = selectedWorkTypes.isEmpty;
      vehicleError = vehicleCtrl.text.trim().isEmpty;
      imageError = image == null;
    });

    if (machineError || workTypeError || vehicleError || imageError) return;

    try {
      final uri = Uri.parse("${KD.api}/app/add_my_machine");
      final request = http.MultipartRequest("POST", uri);

      final machineName =
          selectedMachine!["name_in_english"] ?? selectedMachine!["name"];

      final workTypes = selectedWorkTypes
          .map((w) => w["type_in_english"] ?? w["type"])
          .toList();

      request.fields["userId"] = UserSession.userId ?? "";
      request.fields["vehicleNumber"] = vehicleCtrl.text.trim();
      request.fields["machine[0]"] = machineName;

      for (int i = 0; i < workTypes.length; i++) {
        request.fields["workType[$i]"] = workTypes[i];
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          image!.path,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text("Success".tr()),
            content: Text("Machinery_added_successfully".tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("OK".tr()),
              ),
            ],
          ),
        );
      } else {
        debugPrint("Submit failed: $responseBody");
      }
    } catch (e) {
      debugPrint("Submit error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKannada = Localizations.localeOf(context).languageCode == 'kn';

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F9),
      appBar: AppBar(
        title: Text("List_My_Machinery".tr(),
            style: const TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownMenu<Map<String, dynamic>>(
                      width: MediaQuery.of(context).size.width - 64,
                      hintText: "Select_Machinery".tr(),
                      inputDecorationTheme: _outlineTheme(machineError),
                      dropdownMenuEntries: machineryData.map((m) {
                        final name = isKannada
                            ? (m["name_in_kannada"] ?? m["name_in_english"])
                            : (m["name_in_english"] ?? m["name"]);
                        return DropdownMenuEntry(
                          value: m,
                          label: name,
                          labelWidget: Row(
                            children: [
                              _networkImage(m["image"]),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onSelected: (v) {
                        setState(() {
                          selectedMachine = v;
                          machineError = false;
                          workTypePool = List<Map<String, dynamic>>.from(
                              v?["work_types"] ?? []);
                          selectedWorkTypes.clear();
                        });
                      },
                    ),

                    if (machineError)
                      _error("Please_select_the_machinery_first"),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () {
                        if (selectedMachine == null) {
                          setState(() => machineError = true);
                          return;
                        }
                        _openWorkTypeSelector(isKannada);
                      },
                      child: _box(
                        error: workTypeError,
                        child: selectedWorkTypes.isEmpty
                            ? Text("Select_Work_Type".tr(),
                                style: TextStyle(color: Colors.grey.shade500))
                            : Wrap(
                                spacing: 8,
                                children: selectedWorkTypes.map((w) {
                                  final name = isKannada
                                      ? (w["type_in_kannada"] ??
                                          w["type_in_english"])
                                      : (w["type_in_english"] ?? w["type"]);
                                  return Chip(label: Text(name));
                                }).toList(),
                              ),
                      ),
                    ),

                    if (workTypeError)
                      _error("Please_select_at_least_one_work_type"),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: vehicleCtrl,
                      maxLength: 10,
                      textInputAction: TextInputAction.done,
                      onChanged: (v) {
                        setState(() => vehicleError = false);
                        if (v.length == 10) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      decoration: _vehicleDecoration(vehicleError),
                    ),

                    if (vehicleError) _error("This_field_is_required"),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: image == null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt),
                                  const SizedBox(height: 6),
                                  Text("Please_upload_the_image".tr()),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(image!,
                                    fit: BoxFit.cover,
                                    width: double.infinity),
                              ),
                      ),
                    ),

                    if (imageError) _error("Please_upload_the_image"),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text("Submit".tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _error(String key) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(key.tr(),
            style: const TextStyle(color: Colors.red, fontSize: 12)),
      );

  Widget _box({required Widget child, bool error = false}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: error ? Colors.red : Colors.grey, width: 2),
        ),
        child: child,
      );

  InputDecoration _vehicleDecoration(bool error) => InputDecoration(
        labelText: "Vehicle_Number".tr(),
        counterText: "",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: error ? Colors.red : Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color:
                  error ? Colors.red : const Color.fromARGB(255, 29, 108, 92),
              width: 2.5),
        ),
      );

  InputDecorationTheme _outlineTheme(bool error) => InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: error ? Colors.red : Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color:
                  error ? Colors.red : const Color.fromARGB(255, 29, 108, 92),
              width: 2.5),
        ),
      );
}
