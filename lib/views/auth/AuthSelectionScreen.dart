/**/
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../widgets/AuthOptionCard.dart';
import 'MobileVerificationScreen.dart';
import '../home/HomePage.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset('assets/animations/login.json'),
                      ),
                      SizedBox(height: 16),
                      Text(
                        tr("Welcome to Kisan Desk!"),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        tr("Choose your preferred sign-in method below"),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      AuthOptionCard(
                        lottieFile: 'assets/animations/phone.json',
                        title: tr("Mobile OTP"),
                        subtitle: tr("Login with your phone number"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MobileVerificationScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24),
                      /*
                      // comment this section before release
                      //added for development purposes only
                      ////////////////////////////////////
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1B5E20), // Greenish-teal
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            elevation: 4,
                          ),
                          child: Text(
                            tr("🚀 Skip to Home (Dev Only)"),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      //////////////////////////////////////
                      ///
                      */
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}