// lib/services/address_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'address_model.dart';

class AddressService {
  static const String _key = 'saved_addresses';
  static const int maxAddresses = 5;

  static Future<List<Address>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => Address.fromJson(e)).toList();
  }

  static Future<void> saveAddresses(List<Address> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(addresses.map((a) => a.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<bool> addAddress(Address address) async {
    final addresses = await getAddresses();
    if (addresses.length >= maxAddresses) return false; // limit reached

    // Make first address default
    final newAddr = addresses.isEmpty ? address.copyWith(isDefault: true) : address;
    addresses.add(newAddr);
    await saveAddresses(addresses);
    return true;
  }

  static Future<void> updateAddress(Address updatedAddress) async {
    final addresses = await getAddresses();
    final index = addresses.indexWhere((a) => a.id == updatedAddress.id);
    if (index != -1) {
      addresses[index] = updatedAddress;
      await saveAddresses(addresses);
    }
  }

  static Future<void> deleteAddress(String id) async {
    final addresses = await getAddresses();
    addresses.removeWhere((a) => a.id == id);

    // Re-assign default if deleted
    if (addresses.isNotEmpty && !addresses.any((a) => a.isDefault)) {
      addresses[0] = addresses[0].copyWith(isDefault: true);
    }
    await saveAddresses(addresses);
  }

  static Future<void> setDefaultAddress(String id) async {
    final addresses = await getAddresses();
    final updated = addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    await saveAddresses(updated);
  }

  static Future<Address?> getDefaultAddress() async {
    final addresses = await getAddresses();
    if (addresses.isEmpty) return null;
    return addresses.firstWhere((a) => a.isDefault, orElse: () => addresses[0]);
  }
}