import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class MyTransactionPage extends StatefulWidget {
  @override
  _MyTransactionPageState createState() => _MyTransactionPageState();
}

class _MyTransactionPageState extends State<MyTransactionPage> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final url = Uri.parse('http://3.110.121.159/api/transaction/get_all_transcation_by_user');
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "farmer_id": "671f66a79be5547386def73e",
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          transactions = data['results'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF00AD83),
      //   title: Text('Transactions'),
      // ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? Center(
        child: Text(
          'No transactions found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final farmer = transaction['farmerDetails'][0];
          return ListTile(
            leading: Icon(
              transaction['status'] == 'sold'
                  ? Icons.check_circle
                  : Icons.hourglass_empty,
              color: transaction['status'] == 'sold'
                  ? Colors.green
                  : Colors.orange,
            ),
            title: Text('Transaction ID: ${transaction['transaction_id']}'),
            subtitle: Text(
              '${transaction['crop_name'] ?? 'N/A'} - ${farmer['full_name'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction['amount'] != null
                      ? '₹${transaction['amount']}'
                      : 'Pending Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction['amount'] != null
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction['created_at'] != null
                      ? transaction['created_at'].split('T')[0]
                      : 'Date N/A',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionDetailPage(transaction: transaction),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  TransactionDetailPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final farmer = transaction['farmerDetails'][0];
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
        backgroundColor: Color(0xFF00AD83),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Transaction Info'),
            _buildDetailCard('Transaction ID:', transaction['transaction_id']),
            _buildDetailCard('Crop Name:', transaction['crop_name']),
            _buildDetailCard('Status:', transaction['status']),
            _buildDetailCard('Amount:', transaction['amount'] != null ? '₹${transaction['amount']}' : 'Pending Amount'),
            // _buildDetailCard(
            //   'Transaction Date:',
            //   transaction['created_at'].substring(0, 10),
            // ),
            _buildDetailCard(
              'Transaction Date:',
              transaction['created_at'] != null ? transaction['created_at'].substring(0, 10) : 'Date N/A',
            ),
            SizedBox(height: 20),

            _buildSectionTitle('Farmer Details'),
            _buildDetailCard('Name:', farmer['full_name']),
            _buildDetailCard('Phone:', farmer['phone']),
            _buildDetailCard('Village:', farmer['village']),
            _buildDetailCard('Taluka:', farmer['taluka']),
            _buildDetailCard('District:', farmer['district']),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildDetailCard(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value ?? 'N/A', // Provide a fallback for null values
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
