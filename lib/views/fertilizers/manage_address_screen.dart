// lib/screens/manage_addresses_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'address_model.dart';
import 'address_service.dart';
import 'add_address_screen.dart';
import 'cart_screen.dart';
import 'fertilizer_details_screen.dart';

class ManageAddressesScreen extends StatefulWidget{
  const ManageAddressesScreen({Key? key}) : super(key: key);

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  late Future<List<Address>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _addressesFuture = AddressService.getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My_Addresses', style: TextStyle(fontWeight: FontWeight.bold)).tr(),
        backgroundColor: const Color.fromARGB(255, 29, 108, 92),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Address>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: addresses.isEmpty
                    ? Center(child: Text('No_addresses_saved_yet').tr())
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: addresses.length,
                        itemBuilder: (ctx, i) {
                          final addr = addresses[i];
                          return Card(
                            child: ListTile(
                              leading: addr.isDefault ? const Icon(Icons.star, color: Colors.amber) : null,
                              title: Text(addr.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(addr.fullAddress, maxLines: 2),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final updated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddAddressScreen(existingAddress: addr),
                                        ),
                                      );
                                      if (updated == true) _loadAddresses();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete_Address?').tr(),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel').tr()),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('delete', style: TextStyle(color: Colors.red)).tr(),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await AddressService.deleteAddress(addr.id);
                                        _loadAddresses();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await AddressService.setDefaultAddress(addr.id);
                                if (!mounted) return;
                                Navigator.pop(context, addr); // return selected address
                              },
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: addresses.length >= 5
                        ? null
                        : () async {
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
                            if (result == true) _loadAddresses();
                          },
                    icon: const Icon(Icons.add),
                    label: Text(addresses.length >= 5 ? 'Maximum_5_addresses_allowed'.tr() : 'Add_New_Address'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 108, 92),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}