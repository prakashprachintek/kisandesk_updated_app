import 'package:flutter/material.dart';
import '../services/user_session.dart';

class UserTestPage extends StatelessWidget {
  const UserTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserSession.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _info('User ID', user['_id']),
            _info('User Type', user['user_type']),
            _info('Full Name', user['full_name']),
            _info('Phone', user['phone']),
            _info('Address', user['address']),
            _info('Taluka', user['taluka']),
            _info('District', user['district']),
            _info('Village', user['village']),
            _info('State', user['state']),
            _info('Pincode', user['pincode']),
            _info('DOB', user['dob']),
            _info('Gender', user['gender']),
            _info('Status', user['status']),
            _info('Has Machinery', user['isHaveMachinery']),

            const SizedBox(height: 20),

            /// MACHINES
            const Text(
              'Machinery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...(user['machine_list'] as List? ?? []).map((machine) {
              return Card(
                child: ListTile(
                  title: Text(machine['name'] ?? '-'),
                  subtitle: Text(
                    'Works: ${(machine['works'] as List?)?.join(', ') ?? '-'}',
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            /// ACTIVITY LOG
            const Text(
              'Activity Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...(user['activity_log'] as List? ?? []).map((log) {
              return Card(
                child: ListTile(
                  title: Text(log['action'] ?? '-'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (log['message'] != null)
                        Text(log['message']),
                      Text(
                        'At: ${log['action_at'] ?? '-'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }
}
