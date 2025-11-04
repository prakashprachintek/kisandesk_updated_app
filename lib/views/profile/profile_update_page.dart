import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mainproject1/views/services/user_session.dart';
import '../services/api_config.dart';

/// Loads the static location JSON (district → taluk → village)
Future<Map<String, dynamic>> _loadLocationJson() async {
  final String jsonString =
      await rootBundle.loadString('assets/loadLocation_data.json');
  return json.decode(jsonString);
}

/// ---------------------------------------------------------------------------
///  Profile Update Page (full-screen)
/// ---------------------------------------------------------------------------
class ProfileUpdatePage extends StatefulWidget {
  final String phone;
  final VoidCallback? onSuccess;

  const ProfileUpdatePage({
    Key? key,
    required this.phone,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  // ---------- Controllers ----------
  final _nameController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // ---------- State ----------
  bool _hasSubmitted = false;
  bool _isSubmitting = false;

  // ---------- Dropdown / Date ----------
  String? _selectedDistrict;
  String? _selectedTaluk;
  String? _selectedVillage;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  // ---------- Location data ----------
  List<String> _districts = [];
  List<String> _taluks = [];
  List<String> _villages = [];

  late Map<String, List<dynamic>> _talukasMap;
  late Map<String, List<dynamic>> _villagesMap;

  // -------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // 1. Load static location JSON
    final locationData = await _loadLocationJson();

    // Copy & sort
    _talukasMap = Map.from(locationData['talukas'] as Map);
    _villagesMap = Map.from(locationData['villages'] as Map);

    _talukasMap.forEach((k, v) {
      v.sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    });
    _villagesMap.forEach((k, v) {
      v.sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    });

    // 2. Populate districts (Karnataka only)
    _districts = List<String>.from(locationData['districts']['Karnataka'] ?? []);
    _districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // 3. Pre-fill from UserSession
    final user = UserSession.user;
    _nameController.text = user?['full_name'] ?? '';
    _stateController.text = user?['state'] ?? 'Karnataka';
    _pincodeController.text = user?['pincode'] ?? '';
    _addressController.text = user?['address'] ?? '';

    _selectedDistrict = user?['district'];
    _selectedTaluk = user?['taluka'];
    _selectedVillage = user?['village'];
    _selectedGender = user?['gender'];
    if (_selectedGender?.trim().isEmpty ?? true) _selectedGender = null;

    if (user?['dob'] != null) {
      try {
        _selectedDateOfBirth = DateFormat('dd-MM-yyyy').parse(user!['dob']);
      } catch (_) {}
    }

    // 4. Validate / reset invalid selections
    if (_selectedDistrict != null && !_districts.contains(_selectedDistrict)) {
      _selectedDistrict = null;
      _selectedTaluk = null;
      _selectedVillage = null;
    }

    if (_selectedDistrict == null && _districts.isNotEmpty) {
      _selectedDistrict = _districts.first;
    }

    // 5. Populate taluks & villages
    if (_selectedDistrict != null) {
      _taluks = List<String>.from(_talukasMap[_selectedDistrict!] ?? []);
      if (_selectedTaluk != null && !_taluks.contains(_selectedTaluk)) {
        _selectedTaluk = null;
        _selectedVillage = null;
      }
    }

    if (_selectedTaluk != null) {
      _villages = List<String>.from(_villagesMap[_selectedTaluk!] ?? []);
      if (_selectedVillage != null && !_villages.contains(_selectedVillage)) {
        _selectedVillage = null;
      }
    }

    if (mounted) setState(() {});
  }

  // -------------------------------------------------------------------------
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _pincodeController.text.trim().isNotEmpty &&
        _pincodeController.text.length == 6 &&
        _selectedDistrict != null &&
        _selectedTaluk != null &&
        _selectedVillage != null &&
        _selectedGender != null &&
        _selectedDateOfBirth != null;
  }

  // -------------------------------------------------------------------------
  Future<void> _submit() async {
    setState(() => _hasSubmitted = true);

    if (!_formKey.currentState!.validate()) return;

    // ---- At least one change? (same logic as dialog) ----
    final bool hasChanges = _nameController.text.isNotEmpty ||
        _stateController.text.isNotEmpty ||
        _addressController.text.isNotEmpty ||
        _pincodeController.text.isNotEmpty ||
        _selectedDistrict != null ||
        _selectedTaluk != null ||
        _selectedVillage != null ||
        _selectedGender != null ||
        _selectedDateOfBirth != null;

    if (!hasChanges) {
      _showMessage(tr('Please update at least one field'), isError: true);
      return;
    }

    // ---- Build payload (only changed fields) ----
    final Map<String, dynamic> payload = {
      "_id": UserSession.user?["_id"]
    };
    if (_nameController.text.isNotEmpty) payload["fullName"] = _nameController.text.trim();
    if (_stateController.text.isNotEmpty) payload["state"] = _stateController.text.trim();
    if (_selectedDistrict != null) payload["district"] = _selectedDistrict;
    if (_selectedTaluk != null) payload["taluka"] = _selectedTaluk;
    if (_selectedVillage != null) payload["village"] = _selectedVillage;
    if (_addressController.text.isNotEmpty) payload["address"] = _addressController.text.trim();
    if (_pincodeController.text.isNotEmpty) payload["pincode"] = _pincodeController.text.trim();
    if (_selectedDateOfBirth != null) {
      payload["dob"] = DateFormat('dd-MM-yyyy').format(_selectedDateOfBirth!);
    }
    if (_selectedGender != null) payload["gender"] = _selectedGender;

    // ---- API call ----
    setState(() => _isSubmitting = true);
    try {
      final url = Uri.parse("${KD.api}/user/update_user");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        if (data["userDataVal"] != null) {
          await UserSession.setUser(data["userDataVal"]);
          widget.onSuccess?.call();
          _showMessage(tr('Profile updated successfully'));
          // Pop page after success
          if (mounted) Navigator.of(context).pop();
        } else {
          _showMessage(tr('Error: Updated user data not found'), isError: true);
        }
      } else {
        _showMessage(data["message"] ?? tr('Update failed'), isError: true);
      }
    } catch (e) {
      _showMessage(tr('Error: $e'), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // -------------------------------------------------------------------------
  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Edit Personal Information'),style: TextStyle(fontWeight: FontWeight.bold),),
        // centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ---------- Name ----------
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(tr('Name')),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v?.trim().isEmpty ?? true ? tr('Please enter your name') : null,
                ),
                const SizedBox(height: 12),

                // ---------- Date of Birth ----------
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateOfBirth ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDateOfBirth = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration(tr('Date of Birth')),
                    child: Text(
                      _selectedDateOfBirth == null
                          ? tr('Select Date')
                          : DateFormat('dd-MM-yyyy').format(_selectedDateOfBirth!),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ---------- Gender ----------
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: _inputDecoration(tr('Gender')),
                  hint: Text(tr('Select Gender'), style: TextStyle(color: Colors.grey[600])),
                  isExpanded: true,
                  items: ['Male', 'Female'].map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedGender = v),
                  validator: (v) => v == null ? tr('Please select a gender') : null,
                ),
                const SizedBox(height: 12),

                // ---------- State ----------
                TextFormField(
                  controller: _stateController,
                  decoration: _inputDecoration(tr('State')),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v?.trim().isEmpty ?? true ? tr('Please enter a state') : null,
                ),
                const SizedBox(height: 12),

                // ---------- District ----------
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: _inputDecoration(tr('District')),
                  hint: Text(tr('Select District'), style: TextStyle(color: Colors.grey[600])),
                  isExpanded: true,
                  items: _districts.map((d) {
                    return DropdownMenuItem(value: d, child: Text(d));
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedDistrict = v;
                      _taluks = List<String>.from(_talukasMap[v!] ?? []);
                      _selectedTaluk = null;
                      _villages = [];
                      _selectedVillage = null;
                    });
                  },
                  validator: (v) => v == null ? tr('Please select a district') : null,
                ),
                const SizedBox(height: 12),

                // ---------- Taluka ----------
                DropdownButtonFormField<String>(
                  value: _selectedTaluk,
                  decoration: _inputDecoration(tr('Taluka')),
                  hint: Text(
                    _selectedDistrict == null ? tr('Select District first') : tr('Select Taluka'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  isExpanded: true,
                  items: _taluks
                      .where((t) => t.isNotEmpty)
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: _selectedDistrict == null
                      ? null
                      : (v) {
                          setState(() {
                            _selectedTaluk = v;
                            _villages = List<String>.from(_villagesMap[v!] ?? []);
                            _selectedVillage = null;
                          });
                        },
                  validator: (v) => _selectedDistrict != null && v == null
                      ? tr('Please select a taluka')
                      : null,
                ),
                const SizedBox(height: 12),

                // ---------- Village ----------
                DropdownButtonFormField<String>(
                  value: _selectedVillage,
                  decoration: _inputDecoration(tr('Village')),
                  hint: Text(
                    _selectedTaluk == null ? tr('Select Taluka first') : tr('Select Village'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  isExpanded: true,
                  items: _villages
                      .where((v) => v.isNotEmpty)
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: _selectedTaluk == null ? null : (v) => setState(() => _selectedVillage = v),
                  validator: (v) => _selectedTaluk != null && v == null
                      ? tr('Please select a village')
                      : null,
                ),
                const SizedBox(height: 12),

                // ---------- Address ----------
                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration(tr('Address')),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v?.trim().isEmpty ?? true ? tr('Please enter an address') : null,
                ),
                const SizedBox(height: 12),

                // ---------- Pincode ----------
                TextFormField(
                  controller: _pincodeController,
                  decoration: _inputDecoration(tr('Pincode')),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return tr('Please enter a pincode');
                    if (v.length != 6) return tr('Pincode must be 6 digits');
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ---------- Submit Button ----------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid()
                          ? const Color.fromARGB(255, 29, 108, 92)
                          : Colors.grey[400],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isFormValid() && !_isSubmitting ? _submit : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            tr('Update Details'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}