import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/image_compression.dart';
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
  bool isSubmitting = false;

  bool machineError = false;
  bool workTypeError = false;
  bool vehicleError = false;
  bool imageError = false;

  bool isValidVehicleNumber(String value) {
  final regExp = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$');
  return regExp.hasMatch(value);
}

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

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["status"] == "success") {
          machineryData = List<Map<String, dynamic>>.from(
            data["results"][0]["machinery_type"],
          );
        }
      }
    } catch (e) {
      debugPrint("Fetch machinery error: $e");
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70, // keep as fallback
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (picked == null) return;

    try {
      // ← This is the important part
      final originalFile = File(picked.path);
      final compressedFile =
          await optimizeImage(originalFile); // ← reuse your existing function!

      if (!mounted) return;
      setState(() {
        image = compressedFile;
        imageError = false;
      });
    } catch (e) {
      debugPrint("Compression failed: $e");
      // fallback to original if compression fails (or show error)
      if (mounted) {
        setState(() {
          image = File(picked.path);
          imageError = false;
        });
      }
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
                        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
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

  void _showGenericError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to add machinery. Please try again.".tr()),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      machineError = selectedMachine == null;
      workTypeError = selectedWorkTypes.isEmpty;
      final vehicle = vehicleCtrl.text.trim().toUpperCase();

      vehicleError = vehicle.isEmpty || !isValidVehicleNumber(vehicle);
      imageError = image == null;
    });

    if (machineError || workTypeError || vehicleError || imageError) return;

    if (!mounted) return;
    setState(() => isSubmitting = true);

    try {
      // 1. Get original filename
      final String fileName = image!.path.split(Platform.pathSeparator).last;

      // 2. Upload image first
      final uploadUri = Uri.parse("${KD.api}/upload_document");
      final uploadRequest = http.MultipartRequest('POST', uploadUri);

      print("═══════════════════════════════════════════════");
      print("→ UPLOADING IMAGE TO: $uploadUri");
      print("→ File path: ${image!.path}");
      print("→ File name: ${image!.path.split(Platform.pathSeparator).last}");
      print("═══════════════════════════════════════════════");

      uploadRequest.files
          .add(await http.MultipartFile.fromPath('file', image!.path));

      final uploadResponse = await uploadRequest.send();
      final uploadBody = await uploadResponse.stream.bytesToString();

      print("═══════════════════════════════════════════════");
      print("← IMAGE UPLOAD RESPONSE");
      print("Status: ${uploadResponse.statusCode}");
      print("Headers: ${uploadResponse.headers}");
      print("Body: $uploadBody");
      print("═══════════════════════════════════════════════");

      if (uploadResponse.statusCode >= 400) {
        throw Exception(
            "Image upload failed: ${uploadResponse.statusCode} - $uploadBody");
      }

      // 3. Send metadata as JSON
      final addUri = Uri.parse("${KD.api}/app/add_my_machine");

      final payload = {
        "userId": UserSession.userId ?? "",
        "machine": [
          selectedMachine!["name_in_english"] ?? selectedMachine!["name"] ?? ""
        ],
        "workTypes": selectedWorkTypes
            .map((w) => w["type_in_english"] ?? w["type"] ?? "")
            .where((t) => t.isNotEmpty)
            .toList(),
        "vehicleNumber": vehicleCtrl.text.trim().toUpperCase(),
        "fileName": "",
      };

      print("═══════════════════════════════════════════════");
      print("→ SENDING TO: $addUri");
      print("→ PAYLOAD (JSON):");
      print(jsonEncode(payload)); // ← most important line!
      print("═══════════════════════════════════════════════");

      final addResponse = await http.post(
        addUri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("═══════════════════════════════════════════════");
      print("← ADD MACHINE RESPONSE");
      print("Status: ${addResponse.statusCode}");
      print("Body: ${addResponse.body}");
      print("═══════════════════════════════════════════════");

      if (addResponse.statusCode == 200 || addResponse.statusCode == 201) {
        try {
          final responseData = jsonDecode(addResponse.body);

          if (responseData["status"] == "success") {
            // ── Real success ──
            if (!mounted) return;
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
                      Navigator.pop(context); // or .pushReplacement() etc.
                    },
                    child: Text("OK".tr()),
                  ),
                ],
              ),
            );
          } else {
            // ── HTTP 200 but logical failure ──
            final message = responseData["message"] ?? "Operation failed";
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message.tr(args: [message])), // or just message
                backgroundColor: Colors.orange.shade800,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (parseError) {
          // JSON parsing failed → very unexpected response
          debugPrint("Response parse error: $parseError");
          _showGenericError();
        }
      } else {
        // ── Real server error (400, 500, timeout, etc.) ──
        _showGenericError();
      }
    } catch (e) {
      debugPrint("Submit error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add machinery. Please try again.".tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
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
          : Stack(
              children: [
                SingleChildScrollView(
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
                        // ... (rest of your UI remains the same)
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
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
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
                                    style:
                                        TextStyle(color: Colors.grey.shade500))
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
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[A-Za-z0-9]")),
                          ],
                          onChanged: (v) {
                            final upper = v.toUpperCase();
                            if (v != upper) {
                              vehicleCtrl.value = vehicleCtrl.value.copyWith(
                                text: upper,
                                selection: TextSelection.collapsed(
                                    offset: upper.length),
                              );
                            }
                            setState(() => vehicleError = false);
                          },
                          decoration: _vehicleDecoration(vehicleError),
                        ),

                        if (vehicleError)
                          _error(
                              "Enter valid vehicle number (e.g., AP09AB1234)"),

                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: isSubmitting ? null : _showImagePicker,
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
                            onPressed: isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 29, 108, 92),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text("Submit".tr()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSubmitting)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
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
            color: error ? Colors.red : const Color.fromARGB(255, 29, 108, 92),
            width: 2.5,
          ),
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
            color: error ? Colors.red : const Color.fromARGB(255, 29, 108, 92),
            width: 2.5,
          ),
        ),
      );

  @override
  void dispose() {
    vehicleCtrl.dispose();
    super.dispose();
  }
}
