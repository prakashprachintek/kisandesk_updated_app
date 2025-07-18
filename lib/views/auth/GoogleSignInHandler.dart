
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../home/HomePage.dart';

class GoogleSignInHandler extends StatefulWidget {
  @override
  _GoogleSignInHandlerState createState() => _GoogleSignInHandlerState();
}

class _GoogleSignInHandlerState extends State<GoogleSignInHandler> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _signInWithGoogle();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Navigator.pop(context); // user canceled
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            phoneNumber: '',
            userData: {
              "email": _auth.currentUser?.email,
              "displayName": _auth.currentUser?.displayName,
            },
          ),
        ),
      );

    } catch (e) {
      print("Google Sign-In failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Google Sign-In", style: TextStyle(color: Colors.grey[700])),
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: Center(
        child: Lottie.asset("assets/animations/google.json", width: 180, height: 180),
      ),
    );
  }
}
