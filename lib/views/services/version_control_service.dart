// lib/services/version_control_service.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/src/core/constant/local_db_constant.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import 'api_config.dart';

class VersionControlService {
  // -----------------------------------------------------------------
  // API
  // -----------------------------------------------------------------
  static const String _versionControlUrl = "${KD.api}/app/get_master_data";

  // -----------------------------------------------------------------
  // Public entry point – no BuildContext needed
  // -----------------------------------------------------------------
  static Future<void> checkAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      debugPrint('Current app version: $currentVersion');

      final response = await http.post(
        Uri.parse(_versionControlUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': 'versionControl'}),
      );

      if (response.statusCode != 200) {
        _showSnackBar('Failed to fetch version info: ${response.statusCode}');
        return;
      }

      final data = jsonDecode(response.body);

      if (data['status'] != 'success' ||
          data['results'] is! List ||
          data['results'].isEmpty) {
        _showSnackBar('Invalid API response structure');
        return;
      }

      final firstResult = data['results'][0]; 

      // Version info (inside the "version" object)
      final versionData = firstResult['version'] as Map<String, dynamic>;

      final latestVersion        = versionData['latest_version']?.toString()        ?? '1.0.0';
      final minSupportedVersion  = versionData['min_supported_version']?.toString() ?? '1.0.0';


      final String? supportMobileNumber   = firstResult['supportMobileNumber']?.toString();
      final String? supportWhatsAppNumber = firstResult['supportWhatsAppNumber']?.toString();


      final pref = await SharedPreferences.getInstance();
      await pref.setString(LocalDBConstant.supportMobileNumber.key,   supportMobileNumber   ?? '');
      await pref.setString(LocalDBConstant.supportWhatsAppNumber.key, supportWhatsAppNumber ?? '');

      debugPrint('API response - Latest: $latestVersion, Min Supported: $minSupportedVersion');

      if (_isVersionLower(currentVersion, minSupportedVersion)) {
        debugPrint('Triggering force update dialog');
        _showForceUpdateDialog(latestVersion);
      } else if (_isVersionLower(currentVersion, latestVersion)) {
        debugPrint('Triggering optional update dialog');
        _showOptionalUpdateDialog(latestVersion);
      } else {
        debugPrint('No update required');
      }
    } catch (e) {
      debugPrint('Error checking app version: $e');
      _showSnackBar('Network error while checking version');
    }
  }

  // -----------------------------------------------------------------
  // Helper: version comparison
  // -----------------------------------------------------------------
  static bool _isVersionLower(String current, String required) {
    final cur = current.split('.').map(int.parse).toList();
    final req = required.split('.').map(int.parse).toList();

    for (int i = 0; i < cur.length && i < req.length; i++) {
      if (cur[i] < req[i]) return true;
      if (cur[i] > req[i]) return false;
    }
    return false; // equal or current has extra segments
  }

  // -----------------------------------------------------------------
  // Dialogs – use the global navigator key
  // -----------------------------------------------------------------
  static void _showForceUpdateDialog(String latestVersion) {
    final ctx = MyApp.navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // extra safety for Android back button
        child: AlertDialog(
          title: const Text('Update Required'),
          content: Text(
              'Your app version is outdated. Please update to version $latestVersion to continue using the app.'),
          actions: [
            TextButton(
              onPressed: _launchStore,
              child: Text('Update Now',
                  style: TextStyle(
                      color: Color.fromARGB(255, 29, 108, 92),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  static void _showOptionalUpdateDialog(String latestVersion) {
    final ctx = MyApp.navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('New Version Available'),
        content: Text(
            'A new version ($latestVersion) is available. Would you like to update now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later',
                style: TextStyle(
                    color: Color.fromARGB(255, 29, 108, 92),
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              _launchStore();
              Navigator.of(ctx).pop();
            },
            child: const Text('Update Now',
                style: TextStyle(
                    color: Color.fromARGB(255, 29, 108, 92),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // Helper: SnackBar (also uses navigatorKey)
  // -----------------------------------------------------------------
  static void _showSnackBar(String message) {
    final ctx = MyApp.navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // -----------------------------------------------------------------
  // TODO: Open Play Store / App Store
  // -----------------------------------------------------------------
  static void _launchStore() {
    // Example with url_launcher:
    // final uri = Uri.parse(
    //   Platform.isAndroid
    //       ? 'https://play.google.com/store/apps/details?id=com.your.package'
    //       : 'https://apps.apple.com/app/idYOUR_APP_ID');
    // launchUrl(uri);
  }
}
