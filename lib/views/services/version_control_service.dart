import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_config.dart';

class VersionControlService {
  // API endpoint for version control
  static const String _versionControlUrl = "${KD.api}/app/get_master_data"; // Replace with your actual API endpoint

  // Function to check app version
  static Future<void> checkAppVersion(BuildContext context) async {
    try {
      // Get current app version from package_info_plus
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      print('❕❕❕Current app version: $currentVersion');
      

      // Make API call to get version information
      final response = await http.post(
        Uri.parse(_versionControlUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': 'versionControl'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if response structure is as expected
        if (data['status'] == 'success' && data['results'] is List && data['results'].isNotEmpty) {
          final versionData = data['results'][0]['version'];
          String latestVersion = versionData['latest_version'] ?? '1.0.0'; // Fallback if null
          String minSupportedVersion = versionData['min_supported_version'] ?? '1.0.0'; // Fallback if null
          print('❕❕❕API response - Latest: $latestVersion, Min Supported: $minSupportedVersion'); // Debug log

          if (_isVersionLower(currentVersion, minSupportedVersion)) {
            print('❕❕❕Triggering force update dialog');
            _showForceUpdateDialog(context, latestVersion);
          } else if (_isVersionLower(currentVersion, latestVersion)) {
            print('❕❕❕Triggering optional update dialog');
            _showOptionalUpdateDialog(context, latestVersion);
          } else {
            print('No update required');
          }
        } else {
          print('Invalid API response structure');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to validate app version. Please try again later.')),
          );
       }
      } else {
        // Handle API failure (optional: show error or proceed silently)
        print('Failed to fetch version info: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors (e.g., network issues)
      print('Error checking app version: $e');
    }
  }

  // Helper function to compare version strings (e.g., "1.0.0" < "1.1.0")
  static bool _isVersionLower(String currentVersion, String requiredVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> requiredParts = requiredVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length && i < requiredParts.length; i++) {
      if (currentParts[i] < requiredParts[i]) {
        return true;
      } else if (currentParts[i] > requiredParts[i]) {
        return false;
      }
    }
    return false;
  }

  // Show non-dismissible dialog for force update
  static void _showForceUpdateDialog(BuildContext context, String latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Required'),
          content: Text(
              'Your app version is outdated. Please update to version $latestVersion to continue using the app.'),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: Implement update logic
              },
              child: Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  // Show dismissible dialog for optional update
  static void _showOptionalUpdateDialog(BuildContext context, String latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Version Available'),
          content: Text(
              'A new version ($latestVersion) is available. Would you like to update now?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text('Later'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement update logic
                Navigator.of(context).pop(); // Dismiss dialog after action
              },
              child: Text('Update Now'),
            ),
          ],
        );
      },
    );
  }
}
