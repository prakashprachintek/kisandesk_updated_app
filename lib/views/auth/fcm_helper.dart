import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/api_config.dart';

Future<void> sendFCMTokenToServer(String userId, String fcmToken) async {
  final url = Uri.parse("${KD.api}/given_api");

  try {
    final response = await http.post(url,
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "userId": "userId",
          "fcmToken": fcmToken,
        }));

    final data = jsonDecode(response.body);
    print("🔃 FCM Token Sync Response: $data");

    if (response.statusCode == 200 && data["status"] == "success") {
      print("✅FCM token successfully sent to the server");
    } else {
      print("❗Failed to send the token to server");
    }
  } catch (e) {
    print("❌Error");
  }
}
