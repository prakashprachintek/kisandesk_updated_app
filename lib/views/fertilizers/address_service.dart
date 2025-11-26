// lib/services/address_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'address_model.dart';
import 'package:uuid/uuid.dart';

class AddressService {
  static const String _key = 'saved_addresses';
  static final _uuid = const Uuid();

  // Get all addresses
  static Future<List<Address>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Address.fromJson(json)).toList();
  }

  // Save all addresses
  static Future<void> saveAddresses(List<Address> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(addresses.map((a) => a.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  // Add new address
  static Future<void> addAddress(Address address) async {
    final addresses = await getAddresses();

    // If this is first address → make it default
    final newAddress = addresses.isEmpty
        ? address.copyWith(isDefault: true)
        : address;

    addresses.add(newAddress);
    await saveAddresses(addresses);
  }

  // Set default address
  static Future<void> setDefaultAddress(String id) async {
    final addresses = await getAddresses();
    final updated = addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    await saveAddresses(updated);
  }

  // Delete address
  static Future<void> deleteAddress(String id) async {
    final addresses = await getAddresses();
    addresses.removeWhere((a) => a.id == id);

    // If deleted default → make first one default
    if (addresses.isNotEmpty && !addresses.any((a) => a.isDefault)) {
      addresses[0] = addresses[0].copyWith(isDefault: true);
    }

    await saveAddresses(addresses);
  }

  // Get default address
  static Future<Address?> getDefaultAddress() async {
    final addresses = await getAddresses();
    return addresses.isEmpty ? null : addresses.firstWhere((a) => a.isDefault, orElse: () => addresses[0]);
  }
}