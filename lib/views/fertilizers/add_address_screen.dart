// lib/screens/add_address_screen.dart
import 'package:flutter/material.dart';

import 'address_model.dart';
import 'address_service.dart';


class AddAddressScreen extends StatefulWidget {
  final Address? existingAddress;

  const AddAddressScreen({Key? key, this.existingAddress}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _houseController;
  late TextEditingController _villageController;
  late TextEditingController _talukaController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingAddress?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.existingAddress?.phone ?? '');
    _houseController = TextEditingController(text: widget.existingAddress?.houseDetails ?? '');
    _villageController = TextEditingController(text: widget.existingAddress?.village ?? '');
    _talukaController = TextEditingController(text: widget.existingAddress?.taluka ?? '');
    _districtController = TextEditingController(text: widget.existingAddress?.district ?? '');
    _stateController = TextEditingController(text: widget.existingAddress?.state ?? '');
    _pincodeController = TextEditingController(text: widget.existingAddress?.pincode ?? '');
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final address = Address(
      id: widget.existingAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      houseDetails: _houseController.text.trim(),
      village: _villageController.text.trim(),
      taluka: _talukaController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
    );

    await AddressService.addAddress(address);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAddress == null ? 'Add New Address' : 'Edit Address'),
        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildField(_nameController, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _buildField(_phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildField(_houseController, 'House No., Street, Landmark', Icons.home),
              const SizedBox(height: 12),
              _buildField(_villageController, 'Village', Icons.location_city),
              const SizedBox(height: 12),
              _buildField(_talukaController, 'Taluka / Tehsil', Icons.maps_ugc),
              const SizedBox(height: 12),
              _buildField(_districtController, 'District', Icons.location_on),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField(_stateController, 'State', Icons.public)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_pincodeController, 'Pincode', Icons.pin_drop, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Save Address', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 29, 108, 92)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}