import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'otp_page.dart';
import 'package:flutter/services.dart';
import 'FarmerRegiste_rPage.dart';
import 'Home_page.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText; // Variable to store error message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 38, right: 38),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 160),
            Text(
              tr('verify_phone_number'),
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              tr('enter_phone_description'),
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            SizedBox(height: 84),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: BorderSide(color: Color(0xFF00AD83)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: BorderSide(color: Color(0xFF00AD83)),
                ),
                labelText: tr('phone_number_label'),
                hintText: tr('phone_number_hint'),
                labelStyle: TextStyle(color: Color(0xFF00AD83)),
                errorText: _errorText,
              ),
              onChanged: (value) {
                setState(() {
                  _errorText = null;
                });

                if (value.length == 10) {
                  FocusScope.of(context).unfocus(); // Dismiss the keyboard
                }
              },
            ),

            SizedBox(height: 70),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  final phoneNumber = _phoneController.text.trim();

                  // Validate phone number before navigation
                  if (_isValidPhoneNumber(phoneNumber)) {
                    // Navigate to OTP page with the phone number
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpPage(phoneNumber: phoneNumber),
                        // MaterialPageRoute(builder: (context) => FarmerRegisterPage(),
                      ),
                    );
                  } else {
                    // Show error message if phone number is not valid
                    setState(() {
                      _errorText = tr('error_invalid_phone');
                    });
                  }
                },
                child: Text(
                  tr('get_otp_button'),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00AD83), // Green button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to validate phone number
  bool _isValidPhoneNumber(String phoneNumber) {
    // This exampl
    // e checks for a minimum length of 10 digits
    return RegExp(r'^\d{10}$').hasMatch(phoneNumber);
  }
}