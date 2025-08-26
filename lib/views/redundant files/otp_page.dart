import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../farmers/FarmerRegiste_rPage.dart';
import '../home/HomePage.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  OtpPage({required this.phoneNumber});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  // Controllers for each OTP box
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();

  // FocusNodes to manage focus
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    _otpController1.dispose();
    _otpController2.dispose();
    _otpController3.dispose();
    _otpController4.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    super.dispose();
  }

  // Fetch user data using the phone number
  Future<Map<String, dynamic>?> fetchUserData(String phoneNumber) async {
    final url = Uri.parse('http://3.110.121.159/api/user/get_user_by_phone');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phoneNumber": phoneNumber.trim()}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(
          'Response data: $responseData'); // Add this line to check the response
      if (responseData['status'] == 'success') {
        return responseData['results'];
      } else {
        return null;
      }
    } else {
      print('Error fetching user data: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _verifyOtpAndNavigate() async {
    final enteredOtp = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text;

    if (enteredOtp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Please enter the full OTP"))),
      );
      return;
    }

    final url = Uri.parse("http://13.233.103.50/api/admin/verify_otp");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": widget.phoneNumber,
          "otp": enteredOtp,
        }),
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200 && data["status"] == "success") {
        // Navigate to HomePage (you can pass userData later)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                HomePage(), // or HomePage(phoneNumber: ..., userData: ...)
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incorrect OTP. Please try again.")),
        );
      }
    } catch (e) {
      print("OTP verification failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 175),
            Text(
              tr('verification_code'),
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              tr('otp_sent_to') + ' ${widget.phoneNumber}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 88),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOtpBox(_otpController1, _focusNode1, _focusNode2),
                _buildOtpBox(_otpController2, _focusNode2, _focusNode3),
                _buildOtpBox(_otpController3, _focusNode3, _focusNode4),
                _buildOtpBox(_otpController4, _focusNode4, null),
              ],
            ),
            SizedBox(height: 70),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 386,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        /*
                        // Concatenate the entered OTP digits
                        final enteredOtp = _otpController1.text +
                            _otpController2.text +
                            _otpController3.text +
                            _otpController4.text;
                        // Simulate OTP verification success and fetch user data
                        // _navigateToRegistration();
                        */
                        _verifyOtpAndNavigate();
                      },
                      child: Text(
                        tr('verify_otp'),
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF00AD83), // Green button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      // Add functionality for resending OTP
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('resend_otp'))),
                      );
                    },
                    child: Text(
                      tr('resend_otp_link'),
                      style: TextStyle(
                        color: Color(0xFF00AD83), // Green text color
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(TextEditingController controller, FocusNode focusNode,
      FocusNode? nextFocusNode) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '', // Hides the character counter
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            borderSide: BorderSide(color: Color(0xFF00AD83)), // Default border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF00AD83)), // Focused border
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            // Move focus to the next input box
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              // Dismiss keyboard if this is the last box
              FocusScope.of(context).unfocus();
            }
          }
        },
      ),
    );
  }
}
