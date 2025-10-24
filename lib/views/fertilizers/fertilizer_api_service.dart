import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fertilizer_model.dart';

class FertilizerApiService {
  static const String _fetchFertilizerUrl = 'https://app.kisandesk.com/api/fertilizer/fetch_fertilizer_list';
  static const String _fetchOrdersUrl = 'https://app.kisandesk.com/api/fertilizer/get_fertilizer_requests';
  static const String _bookFertilizerUrl = 'https://app.kisandesk.com/api/fertilizer/book_fertilizer';

  Future<FertilizerResponse> fetchFertilizers() async {
    try {
      final response = await http.post(Uri.parse(_fetchFertilizerUrl));
      if (response.statusCode == 200) {
        return FertilizerResponse.fromJsonString(response.body);
      } else {
        throw Exception('Failed to load fertilizers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fertilizers: $e');
    }
  }

  Future<FertilizerOrderResponse> fetchFertilizerOrders(String farmerId) async {
    try {
      final response = await http.post(
        Uri.parse(_fetchOrdersUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'farmerId': farmerId}),
      );
      if (response.statusCode == 200) {
        return FertilizerOrderResponse.fromJsonString(response.body);
      } else {
        throw Exception('Failed to load fertilizer orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fertilizer orders: $e');
    }
  }

  Future<Map<String, dynamic>> bookFertilizerOrder({
    required String userId,
    required List<Map<String, String>> products,
    required String amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_bookFertilizerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'products': products,
          'amount': amount,
          'Payment_mode': 'cash on delivery',
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to book fertilizer order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error booking fertilizer order: $e');
    }
  }
}