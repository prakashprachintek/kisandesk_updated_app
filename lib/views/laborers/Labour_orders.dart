import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/laborers/Requestdetails.dart';
import 'dart:convert';
import '../services/user_session.dart';
import '../services/api_config.dart';

class LabourRequestOrdersPage extends StatelessWidget {
  //final Map<String, dynamic> userData;

  const LabourRequestOrdersPage({Key? key,}) : super(key: key);

  // Fetches labour requests from your API
  Future<List<Map<String, dynamic>>> _fetchLabourRequests() async {
    final Uri apiUrl = Uri.parse('${KD.api}/admin/get_labours_request');
    Map<String, String> body = {
      'farmer_id': UserSession.userId.toString() ?? '',
    };
    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success' && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception("Failed to load labour requests: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching labour requests: $e");
      throw Exception("Failed to load labour requests: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Labour Requests Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.lightGreen, // Example color
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLabourRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Labour Requests Available"));
          }

          List<Map<String, dynamic>> requests = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final item = requests[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestDetailsPage(requestData: item),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['work']?.toString() ?? 'No Work Description',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 16),
                            const SizedBox(width: 8),
                            Text('Date: ${item['work_date_from']?.toString() ?? 'N/A'}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 8),
                            Text('Gender: ${item['labour_type']?.toString() ?? 'N/A'}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16),
                            const SizedBox(width: 8),
                            Text('Status: ${item['status']?.toString() ?? 'N/A'}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}