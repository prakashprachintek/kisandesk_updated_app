import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Centralized user session management with:
/// - In-memory caching
/// - Persistent storage via SharedPreferences
/// - Synchronized state between memory and disk
class UserSession {
  // In-memory cache to avoid repeated SharedPreferences reads
  static Map<String, dynamic>? currentUser;

  /// Persists user data to both memory and disk
  /// Warning: Overwrites existing data completely
  // static Future<void> setUser(Map<String, dynamic> userData) async {
  //   currentUser = userData; // Update memory cache
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('userData', jsonEncode(userData)); // Atomic write
  // }

  static Future<void> setUser(Map<String, dynamic> userData) async {
  final prefs = await SharedPreferences.getInstance();

  // Load existing user (if any)
  String? existingJson = prefs.getString('userData');
  Map<String, dynamic> mergedData = {};

  if (existingJson != null) {
    try {
      mergedData = jsonDecode(existingJson);
    } catch (_) {
      // If existing data is corrupted, ignore it
      mergedData = {};
    }
  }

  // Merge old + new data (new values overwrite old ones)
  mergedData.addAll(userData);

  // Update in-memory + persistent
  currentUser = mergedData;
  await prefs.setString('userData', jsonEncode(mergedData));
}


  /// Loads user from disk to memory (call at app startup)
  /// Silent failure - returns null if no user exists/corrupted data
  static Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');
    if (userString != null) {
      try {
        currentUser = jsonDecode(userString); // May throw on malformed JSON
      } catch (_) {
        await prefs.remove('userData'); // Clean corrupt data
      }
    }
  }

  /// Accessors with null safety:
  static Map<String, dynamic>? get user => currentUser; // Full data access
  
  /// Primary ID accessor (most commonly used field)
  /// Usage: `UserSession.userId` (returns null if logged out)
  static String? get userId => currentUser?['_id']; // Assumes MongoDB-style '_id'

  /// Clears session everywhere (memory + storage)
  /// Note: No API call to invalidate server session
  static Future<void> logout() async {
    currentUser = null; // Clear memory
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData'); // Clear storage
  }
}