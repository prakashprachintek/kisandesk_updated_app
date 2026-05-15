// lib/views/fertilizers/fertilizer_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/fertilizers/fertilizer_offer_model.dart';
import 'package:mainproject1/views/services/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart';
import 'fertilizer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FertilizerApiService {
  static const String _fetchFertilizerUrl =
      '${KD.api}/fertilizer/fetch_fertilizer_list';
  static const String _fetchOrdersUrl =
      '${KD.api}/fertilizer/get_fertilizer_requests';
  static const String _bookFertilizerUrl =
      '${KD.api}/fertilizer/book_fertilizer';
  static const String _addRatingUrl = '${KD.api}/fertilizer/add_rating';
  static const String _fertilizersOfferUrl = '${KD.api}/app/get_master_data';
  static const String _cancelOrderUrl =
      '${KD.api}/fertilizer/cancel_fertilizer_order';
  static const String _markOrderDeliveredUrl =
      '${KD.api}/fertilizer/mark_as_delivered';

  Future<FertilizerResponse> fetchFertilizers() async {
    try {
      final response = await http.post(
        Uri.parse(_fetchFertilizerUrl),
        headers: {'content-Type': 'application/json'},
        body: jsonEncode({
          "userId": UserSession.userId,
        }),
        );
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        final discount = json['discount'] ?? 0;
        await prefs.setDouble('fertilizer_discount', discount.toDouble());

        return FertilizerResponse.fromJson(json);
      } else {
        throw Exception('Failed to load fertilizers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fertilizers: $e');
    }
  }

  // In FertilizerApiService class
  Future<RichFertilizerOrderResponse> fetchFertilizerOrders(
      String farmerId) async {
    try {
      final response = await http.post(
        Uri.parse(_fetchOrdersUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'farmerId': farmerId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return RichFertilizerOrderResponse.fromJson(json);
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<Map<String, dynamic>> bookFertilizerOrder({
    required String userId,
    required List<Map<String, String>> products,
    required String amount,
    required String address,
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
          'deliveryAddress': address,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to book fertilizer order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error booking fertilizer order: $e');
    }
  }

  //Ratings
  Future<Map<String, dynamic>> addRating({
    required String fid,
    required String userId,
    required String rating,
    required String comment,
  }) async {
    final Map<String, dynamic> body = {
      "comment": comment,
      "rating": rating,
      "fid": fid,
      "userId": userId,
    };

    print("Request Body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        Uri.parse(_addRatingUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Review Error: $e');
      rethrow;
    }
  }

  //Offers
  Future<List<Offer>> fetchFertilizerOffers() async {
    const url = _fertilizersOfferUrl;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': 'fertilizer-offers'}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final offerResponse = OfferResponse.fromJson(jsonData);
        return offerResponse.offers;
      } else {
        print('Failed to load offers: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching offers: $e');
      return [];
    }
  }

  //Order Cancellation
  Future<Map<String, dynamic>> cancelFertilizerOrder({
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_cancelOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
        }),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return jsonResponse; // Usually { "status": "success", "message": "..." }
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }

  //Delivery Partner Orders
  Future<RichFertilizerOrderResponse> fetchDeliveryPartnerOrders(
      String deliveryPartnerId) async {
    try {
      final response = await http.post(
        Uri.parse(_fetchOrdersUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'isDeliveryPartner': 'true', // string, not boolean!
          'assignee': deliveryPartnerId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // Delivery partner returns { "results": [ ... ] }
        final List<dynamic> resultsList =
            json['results'] as List<dynamic>? ?? [];

        return RichFertilizerOrderResponse(
          status: json['status'] ?? 'success',
          message: json['message'] ?? '',
          results: resultsList
              .map((item) =>
                  RichFertilizerOrder.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      } else {
        throw Exception(
            'Failed to load delivery orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching delivery orders: $e');
    }
  }

  // Mark Order as Delivered
  Future<Map<String, dynamic>> markAsDelivered(
      {required String orderId}) async {
    try {
      final response = await http.post(
        Uri.parse(_markOrderDeliveredUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
        }),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success
        return jsonResponse; // e.g., { "status": "success", "message": "Order marked as delivered" }
      } else {
        throw Exception(
            jsonResponse['message'] ?? 'Failed to mark as delivered');
      }
    } catch (e) {
      throw Exception('Error marking order as delivered: $e');
    }
  }
}
