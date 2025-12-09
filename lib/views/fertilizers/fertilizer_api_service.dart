// lib/views/fertilizers/fertilizer_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/fertilizers/fertilizer_offer_model.dart';
import '../services/api_config.dart';
import 'fertilizer_model.dart';

// 🔑 NEW IMPORTS FOR CLIENT-SIDE PHONEPE CHECKSUM (UAT ONLY)
import 'package:crypto/crypto.dart'; 
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

// ⚠️ UAT/SANDBOX CREDENTIALS - DO NOT USE IN PRODUCTION
const String UAT_SALT_KEY = '96434309-7796-489d-8924-ab56988a6076';
const int UAT_SALT_INDEX = 1;
const String UAT_MERCHANT_ID = 'PGTESTPAYUAT';

class FertilizerApiService {
  // --- EXISTING ENDPOINTS ---
  static const String _fetchFertilizerUrl =
      '${KD.api}/fertilizer/fetch_fertilizer_list';
  static const String _fetchOrdersUrl =
      '${KD.api}/fertilizer/get_fertilizer_requests';
  static const String _bookFertilizerUrl =
      '${KD.api}/fertilizer/book_fertilizer';
  static const String _addRatingUrl = '${KD.api}/fertilizer/add_rating';
  static const String _fertilizersOfferUrl = '${KD.api}/app/get_master_data';

  // --- MOCK PHONEPE ENDPOINTS (Kept for future backend integration) ---
  // NOTE: This ngrok URL may change.
  static const String _backendBaseUrl = 'https://mock.phonepe.backend.url.placeholder'; 
  static const String _phonePeInitiateUrl = '$_backendBaseUrl/phonepe/initiate'; 
  static const String _phonePeStatusUrl = '$_backendBaseUrl/phonepe/status'; 

  // --- UTILITY METHOD FOR CHECKSUM (UAT ONLY) ---
  String _getChecksum(String base64Payload) {
    const String apiEndpoint = '/pg/v1/pay';
    final String combinedString = '$base64Payload$apiEndpoint$UAT_SALT_KEY';
    final List<int> bytes = utf8.encode(combinedString);
    final String sha256Value = sha256.convert(bytes).toString();
    return '$sha256Value###$UAT_SALT_INDEX';
  }

  // 1. fetchFertilizers (Unchanged)
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

  // 2. fetchFertilizerOrders (Unchanged)
  Future<RichFertilizerOrderResponse> fetchFertilizerOrders(String farmerId) async {
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

  // 3. bookFertilizerOrder (MODIFIED to accept paymentMode)
  Future<Map<String, dynamic>> bookFertilizerOrder({
    required String userId,
    required List<Map<String, String>> products,
    required String amount,
    required String address,
    required String paymentMode, // 🔑 NEW PARAMETER
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_bookFertilizerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'products': products,
          'amount': amount,
          // 🔑 Use the dynamic mode here
          'Payment_mode': paymentMode, 
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

  // 4. addRating (Unchanged)
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

  // 5. fetchFertilizerOffers (Unchanged)
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

  // ------------------------------------------------------------------
  // ⚡ PHONEPE INTEGRATION METHODS (IMPLEMENTED FOR UAT) ⚡
  // ------------------------------------------------------------------

  /// Initializes the PhonePe SDK (must be called once at app startup).
  Future<void> initializePhonePeSDK() async {
    bool response = await PhonePePaymentSdk.init(
      'SANDBOX',
      null,
      UAT_MERCHANT_ID, 
      // Replace 'com.example.mainproject1' with your actual Android package name
      //'com.example.mainproject1', 
      true,
    // Use 'SANDBOX' for UAT testing
 // ✅ FIX: This must be a String, not cast as bool.
    );
    print('PhonePe SDK Init Response: $response');
  }

  /// Initiates a PhonePe payment transaction using client-side generated payload (UAT only).
  Future<Map<String, dynamic>> initiatePhonePePayment({
    required String userId,
    required String amount, // Expects Rupees (String)
  }) async {
    final merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Safety check for parsing the amount and converting to Paisa
    final double amountInRupees = double.tryParse(amount) ?? 0.0;
    final int amountInPaisa = (amountInRupees * 100).round();
    
    // 1. Construct the Payload
    final Map<String, dynamic> requestPayload = {
      "merchantId": UAT_MERCHANT_ID,
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": userId, 
      "amount": amountInPaisa, 
      "callbackUrl": 'flutterphonepe://callback',
      "redirectUrl": 'flutterphonepe://callback',
      "paymentInstrument": {"type": "PAY_PAGE"},
      "redirectMode": "REDIRECT",
    };

    // 2. Encode to Base64
    final String base64Payload = base64.encode(utf8.encode(json.encode(requestPayload)));

    // 3. Calculate Checksum
    final String checksum = _getChecksum(base64Payload);

    // 4. Start Transaction
    try {
      // The startTransaction function launches the payment process
      final Map<dynamic, dynamic>? response = await PhonePePaymentSdk.startTransaction(
        base64Payload,
        checksum,
        "android", 
        'flutterphonepe://callback',
      );
      
      // The response map contains the final status
      // We safely convert the dynamic Map from the SDK to a consistent type
      return Map<String, dynamic>.from(response ?? {'status': 'UNKNOWN', 'message': 'Empty SDK response'});

    } catch (e) {
      // This catch handles exceptions before the transaction starts (e.g., SDK not initialized)
      return {'status': 'FAILURE', 'error': e.toString()};
    }
  }

  /// Status check stub for client-side UAT flow.
  Future<Map<String, dynamic>> checkPhonePePaymentStatus(String transactionId) async {
    print('Note: Status check method called for $transactionId. Rely on startTransaction result.');
    return {'status': 'success', 'code': 'UAT_SIMULATED_SUCCESS', 'message': 'Simulated status check.'};
  }
}