import 'dart:convert';
import 'package:http/http.dart' as http;

class ModuleService {
  static const String apiUrl = 'https://app.kisandesk.com/api/app/get_master_data';

  /// Fetches the status of all relevant modules from the API.
  /// Returns a Map<String, bool> where the key is the module name (e.g., 'labours').
  Future<Map<String, bool>> fetchModuleStatus() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        // The body from the original prompt was {"type": "appSettings"}
        body: json.encode({'type': 'appSettings'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Correctly navigate the JSON to the 'features' map:
        // data['results'][0]['features']
        if (data['results'] != null && data['results'].isNotEmpty) {
          final moduleSettings = data['results'][0]['features'] as Map<String, dynamic>;
          
          // Map the dynamic values to booleans
          return moduleSettings.map((key, value) => MapEntry(key, value as bool));
        }
        return {}; 
      } else {
        print('Failed to load module status: ${response.statusCode}');
        return {}; 
      }
    } catch (e) {
      print('Network or parsing error fetching module status: $e');
      return {}; 
    }
  }
}