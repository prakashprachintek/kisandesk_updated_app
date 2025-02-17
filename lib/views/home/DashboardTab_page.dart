import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;
  DashboardTab({required this.phoneNumber,required this.userData});

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List<dynamic> _dashboardData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    const String apiUrl = 'http://3.110.121.159/api/admin/get_labours_request';
    const Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map<String, String> body = {
      'farmer_id': widget.userData['farmer_id'],
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _dashboardData = data['results'] ?? [];
            _isLoading = false;
          });
        } else {
          _handleError('Failed to fetch data: ${data['message']}');
        }
      } else {
        _handleError('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _handleError(String errorMessage) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Text(
        'No Data Available',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildDashboardItem(dynamic item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['work'] ?? 'No Work Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text('From: ${item['work_date_from'] ?? 'N/A'}'),
            Text('To: ${item['work_date_to'] ?? 'N/A'}'),
            Text('Status: ${item['status'] ?? 'N/A'}'),
            Text('Male Labour: ${item['total_male_labours'] ?? 0}'),
            Text('Female Labour: ${item['total_female_labours'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardList() {
    return ListView.builder(
      itemCount: _dashboardData.length,
      itemBuilder: (context, index) {
        return _buildDashboardItem(_dashboardData[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? _buildLoadingIndicator()
          : _dashboardData.isEmpty
          ? _buildNoDataMessage()
          : _buildDashboardList(),
    );
  }
}
