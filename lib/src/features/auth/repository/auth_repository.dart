import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mainproject1/src/core/network/api_client.dart';
import 'package:mainproject1/views/services/api_config.dart';

class AuthRepository {
  final ApiClient _apiClient;
  AuthRepository(this._apiClient);
  Future<Map<String, dynamic>> generateOtp(String phoneNumber) async {
    final url = Uri.parse("${KD.api}/admin/generate_otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phoneNumber": phoneNumber}),
    );

    return jsonDecode(response.body);
  }

  // Future<Map<String, dynamic>> insertUser(Map<String, dynamic> body) async {
  //   final url = Uri.parse("${KD.api}/user/insert_user");
  //   final response = await http.post(
  //     url,
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode(body),
  //   );
  //
  //   return jsonDecode(response.body);
  // }
}
