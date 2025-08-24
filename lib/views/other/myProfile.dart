import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/user_session.dart';

class Myprofile extends StatelessWidget {
  const Myprofile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = UserSession.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'.tr()),
      ),
      body: userData == null
          ? Center(child: Text('No user data available'.tr()))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Personal Details'.tr()),
                  _buildInfoCard(context, {
                    'User ID'.tr(): userData['_id'],
                    'User Type'.tr(): userData['user_type'],
                    'Full Name'.tr(): userData['full_name'],
                    'Phone'.tr(): userData['phone'],
                  }),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Address Details'.tr()),
                  _buildInfoCard(context, {
                    'Address'.tr(): userData['address']?.isEmpty ?? true
                        ? 'Not provided'.tr()
                        : userData['address'],
                    'Taluka'.tr(): userData['taluka'],
                    'District'.tr(): userData['district'],
                    'Village'.tr(): userData['village'],
                    'State'.tr(): userData['state']?.isEmpty ?? true
                        ? 'Not provided'.tr()
                        : userData['state'],
                    'Pincode'.tr(): userData['pincode']?.isEmpty ?? true
                        ? 'Not provided'.tr()
                        : userData['pincode'],
                  }),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Additional Information'.tr()),
                  _buildInfoCard(context, {
                    'Date of Birth'.tr(): userData['dob']?.isEmpty ?? true
                        ? 'Not provided'.tr()
                        : userData['dob'],
                    'Gender'.tr(): userData['gender']?.isEmpty ?? true
                        ? 'Not provided'.tr()
                        : userData['gender'],
                    'Status'.tr(): userData['status'],
                    'Wallet Balance'.tr(): '₹${userData['wallet_balance']}',
                  }),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Machinery'.tr()),
                  _buildMachineryCard(context, userData),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Map<String, String?> info) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: info.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(entry.value ?? 'N/A'.tr()),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMachineryCard(
      BuildContext context, Map<String, dynamic> userData) {
    bool hasMachinery = userData['isHaveMachinery'] ?? false;
    List<dynamic> machineList = userData['machine_list'] ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasMachinery
                  ? 'Has Machinery: Yes'.tr()
                  : 'Has Machinery: No'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (hasMachinery && machineList.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...machineList.map((machine) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Machine: ${machine['name']}'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Works: ${(machine['works'] as List<dynamic>).join(', ')}'
                          .tr(),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
