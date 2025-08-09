import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserSession {
  static Map<String, dynamic>? currentUser;

  static Future<void> setUser(Map<String, dynamic> userData) async {
    currentUser = userData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData)); // Store full user
  }
  //use user session like this --> UserSession.userId

  static Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');
    if (userString != null) {
      currentUser = jsonDecode(userString);
    }
  }

  static Map<String, dynamic>? get user => currentUser;

  static String? get userId => currentUser?['_id'];

  static Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
}