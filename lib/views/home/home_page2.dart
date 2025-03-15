// import 'dart:convert';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;

// // If using localization, import easy_localization and set up accordingly
// import 'package:easy_localization/easy_localization.dart';

// // Import your additional pages
// import 'package:mainproject1/views/profile/profile_page.dart';
// import 'package:mainproject1/views/other/favoritePage.dart';
// import 'package:mainproject1/views/other/add_page.dart';
// import 'package:mainproject1/views/other/tabpage.dart';
// import 'package:mainproject1/views/marketplace/Mraket_page1.dart';
// import 'package:mainproject1/views/marketplace/mandiRates.dart';
// import 'package:mainproject1/views/whether/whetherinfo.dart';
// import 'package:mainproject1/views/laborers/LabourRequest.dart';
// import 'package:mainproject1/views/cattle/Cattle_Page.dart';
// import 'package:mainproject1/views/machinery/Machinery_Page.dart';
// import 'package:mainproject1/views/agriculture/Land_page.dart';
// import 'package:mainproject1/views/farmers/FarmerPage.dart';
// // and so on for any additional imports you need.

// // --------------------- MAIN APP --------------------- //

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   // If using EasyLocalization:
//   await EasyLocalization.ensureInitialized();

//   runApp(
//     EasyLocalization(
//       supportedLocales: [Locale('en'), Locale('kn'), Locale('hi'), Locale('mr')],
//       path: 'assets/lang',
//       fallbackLocale: Locale('en'),
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My Branded Auth App',
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: context.localizationDelegates,
//       supportedLocales: context.supportedLocales,
//       locale: context.locale,
//       theme: _buildThemeData(),
//       home: SplashScreen(),
//     );
//   }

//   ThemeData _buildThemeData() {
//     return ThemeData(
//       primaryColor: Color(0xFF00AD83),
//       colorScheme: ColorScheme.fromSwatch(
//         primarySwatch: Colors.teal,
//       ).copyWith(
//         secondary: Colors.orangeAccent,
//       ),
//       scaffoldBackgroundColor: Colors.white,
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           foregroundColor: Colors.white,
//           backgroundColor: Color(0xFF00AD83),
//           minimumSize: Size.fromHeight(48),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Color(0xFF00AD83), width: 2),
//         ),
//       ),
//     );
//   }
// }

// // --------------------- SPLASH SCREEN --------------------- //

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Simulate a 2-second delay, then move to AuthSelectionScreen
//     Future.delayed(Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => AuthSelectionScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Theme.of(context).primaryColor,
//         child: Center(
//           child: Text(
//             "Farmer Tech App",
//             style: TextStyle(
//               fontSize: 28,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --------------------- AUTH SELECTION SCREEN --------------------- //

// class AuthSelectionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Authentication Options"),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => MobileVerificationScreen()),
//               ),
//               child: Text("Sign Up / Login with Mobile"),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => GoogleSignInHandler()),
//               ),
//               child: Text("Sign In with Google"),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => EmailAuthSelectionScreen()),
//               ),
//               child: Text("Sign In with Email / Password"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --------------------- PHONE AUTH FLOW --------------------- //

// class MobileVerificationScreen extends StatefulWidget {
//   @override
//   _MobileVerificationScreenState createState() => _MobileVerificationScreenState();
// }

// class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   bool isValidPhoneNumber(String phone) {
//     // Basic check +countrycode format
//     final regex = RegExp(r'^\+\d{8,15}$');
//     return regex.hasMatch(phone);
//   }

//   Future<void> verifyPhoneNumber() async {
//     final phoneNumber = phoneController.text.trim();
//     if (!isValidPhoneNumber(phoneNumber)) {
//       _showMessage("Invalid phone number format, please include +countryCode.");
//       return;
//     }

//     await _auth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         try {
//           await _auth.signInWithCredential(credential);
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomePage(phoneNumber: phoneNumber, userData: {}),
//             ),
//           );
//         } catch (e) {
//           _showMessage("Auto sign-in failed: $e");
//         }
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         _showMessage("Verification failed: ${e.message}");
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OTPVerificationScreen(
//               verificationId: verificationId,
//               phoneNumber: phoneNumber,
//             ),
//           ),
//         );
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         print("Auto retrieval timeout for $verificationId");
//       },
//     );
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Mobile Verification")),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: phoneController,
//               decoration: InputDecoration(labelText: "Enter +countryCode + number"),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: verifyPhoneNumber,
//               child: Text("Send OTP"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OTPVerificationScreen extends StatefulWidget {
//   final String verificationId;
//   final String phoneNumber;
//   OTPVerificationScreen({required this.verificationId, required this.phoneNumber});

//   @override
//   _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
// }

// class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
//   final TextEditingController otpController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> verifyOTP() async {
//     final otp = otpController.text.trim();
//     if (otp.isEmpty) {
//       _showMessage("Please enter the OTP");
//       return;
//     }

//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: otp,
//       );
//       await _auth.signInWithCredential(credential);

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomePage(phoneNumber: widget.phoneNumber, userData: {}),
//         ),
//       );
//     } catch (e) {
//       _showMessage("OTP verification failed: $e");
//     }
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     otpController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("OTP Verification")),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text("OTP sent to: ${widget.phoneNumber}"),
//             SizedBox(height: 16),
//             TextField(
//               controller: otpController,
//               decoration: InputDecoration(labelText: "Enter OTP"),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: verifyOTP,
//               child: Text("Verify OTP"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --------------------- GOOGLE SIGN-IN FLOW --------------------- //

// class GoogleSignInHandler extends StatefulWidget {
//   @override
//   _GoogleSignInHandlerState createState() => _GoogleSignInHandlerState();
// }

// class _GoogleSignInHandlerState extends State<GoogleSignInHandler> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   @override
//   void initState() {
//     super.initState();
//     _signInWithGoogle();
//   }

//   Future<void> _signInWithGoogle() async {
//     try {
//       final googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         Navigator.pop(context); // user cancelled
//         return;
//       }
//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       await _auth.signInWithCredential(credential);

//       // Could fetch phoneNumber or other data from Firestore if needed
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomePage(
//             phoneNumber: '', // Google user might not have phoneNumber
//             userData: {
//               "email": _auth.currentUser?.email,
//               "displayName": _auth.currentUser?.displayName,
//             },
//           ),
//         ),
//       );
//     } catch (e) {
//       print("Google Sign-In failed: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Google Sign-In failed: $e")),
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Google Sign-In"),
//       ),
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }

// // --------------------- EMAIL & PASSWORD FLOW --------------------- //

// class EmailAuthSelectionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Email / Password Auth")),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ElevatedButton(
//               child: Text("Sign In with Email"),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => EmailSignInScreen()));
//               },
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               child: Text("Sign Up (Register) with Email"),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => EmailSignUpScreen()));
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class EmailSignInScreen extends StatefulWidget {
//   @override
//   _EmailSignInScreenState createState() => _EmailSignInScreenState();
// }

// class _EmailSignInScreenState extends State<EmailSignInScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();

//   Future<void> _signIn() async {
//     final email = emailCtrl.text.trim();
//     final pass = passCtrl.text.trim();
//     if (email.isEmpty || pass.isEmpty) {
//       _showMessage("Please fill in both email and password");
//       return;
//     }
//     try {
//       final userCred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomePage(
//             phoneNumber: '', // if you didn't collect phone during email sign in
//             userData: {"email": userCred.user?.email},
//           ),
//         ),
//       );
//     } catch (e) {
//       _showMessage("Sign-In failed: $e");
//     }
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     emailCtrl.dispose();
//     passCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Sign In with Email")),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailCtrl,
//               decoration: InputDecoration(labelText: "Email"),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: passCtrl,
//               decoration: InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _signIn,
//               child: Text("Sign In"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class EmailSignUpScreen extends StatefulWidget {
//   @override
//   _EmailSignUpScreenState createState() => _EmailSignUpScreenState();
// }

// class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();

//   Future<void> _signUp() async {
//     final email = emailCtrl.text.trim();
//     final pass = passCtrl.text.trim();
//     if (email.isEmpty || pass.isEmpty) {
//       _showMessage("Please fill in both fields");
//       return;
//     }
//     try {
//       final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
//       // Optionally store user info in Firestore or your backend if needed.
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => HomePage(
//             phoneNumber: '',
//             userData: {"email": userCred.user?.email},
//           ),
//         ),
//       );
//     } catch (e) {
//       _showMessage("Sign-Up failed: $e");
//     }
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     emailCtrl.dispose();
//     passCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Sign Up with Email")),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailCtrl,
//               decoration: InputDecoration(labelText: "Email"),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: passCtrl,
//               decoration: InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _signUp,
//               child: Text("Create Account"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --------------------- REAL HOME PAGE (Fetching user data) --------------------- //

// class HomePage extends StatefulWidget {
//   final String phoneNumber;
//   final Map<String, dynamic> userData;

//   HomePage({
//     required this.phoneNumber,
//     required this.userData,
//   });

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;

//   // This fetches user data from your endpoint using phoneNumber
//   Future<Map<String, dynamic>?> fetchUserData(String phoneNumber) async {
//     final url = Uri.parse('http://3.110.121.159/api/user/get_user_by_phone');
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"phoneNumber": phoneNumber.trim()}),
//     );

//     print("Home page response: ${response.body}");
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       print("Decoded Response: $responseData");

//       if (responseData['status'] == 'success') {
//         return responseData['results'];
//       } else {
//         print("Status not success: ${responseData['status']}");
//         return null;
//       }
//     } else {
//       print("Error Status Code: ${response.statusCode}");
//       return null;
//     }
//   }

//   // Tapping the leading avatar -> fetch user data -> go to profile
//   void _handleProfileTap() async {
//     final userData = await fetchUserData(widget.phoneNumber);
//     if (userData != null) {
//       print("User Data Loaded: $userData");
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ProfilePage(
//             userData: userData,
//             phoneNumber: widget.phoneNumber,
//           ),
//         ),
//       );
//     } else {
//       print("Failed to load user data");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to load user data")),
//       );
//     }
//   }

//   // Handling bottom nav taps
//   void _onItemTapped(int index) async {
//     setState(() {
//       _selectedIndex = index;
//     });
//     // index 1 => Add button tap
//     // index 2 => Market / Tabbed page
//     if (index == 1) {
//       final userData = await fetchUserData(widget.phoneNumber);
//       if (userData != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AddMarketPostPage(
//               userData: userData,
//               phoneNumber: widget.phoneNumber,
//               isUserExists: true,
//             ),
//           ),
//         );
//       } else {
//         print("Failed to load user data for AddPage");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to load user data")),
//         );
//       }
//     } else if (index == 2) {
//       final userData = await fetchUserData(widget.phoneNumber);
//       if (userData != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TabbedPage(
//               userData: userData,
//               phoneNumber: widget.phoneNumber,
//             ),
//           ),
//         );
//       } else {
//         print("Failed to load user data for tab page");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to load user data")),
//         );
//       }
//     }
//     // index 0 = home
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Farmer Tech Store',
//           style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Color(0xFF00AD83),
//         leading: GestureDetector(
//           onTap: _handleProfileTap,
//           child: CircleAvatar(
//             backgroundImage: AssetImage('assets/profile.jpg'),
//           ),
//         ),
//         actions: [
//           // Language dropdown
//           DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               icon: Text(
//                 'A+',
//                 style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               items: <String>[
//                 'Kannada',
//                 'English',
//                 'Hindi',
//                 'Marathi',
//               ].map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   Locale selectedLocale;
//                   switch (newValue.toLowerCase()) {
//                     case 'kannada':
//                       selectedLocale = Locale('kn');
//                       break;
//                     case 'english':
//                       selectedLocale = Locale('en');
//                       break;
//                     case 'hindi':
//                       selectedLocale = Locale('hi');
//                       break;
//                     case 'marathi':
//                       selectedLocale = Locale('mr');
//                       break;
//                     default:
//                       selectedLocale = Locale('en');
//                   }
//                   context.setLocale(selectedLocale);
//                 }
//               },
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.favorite_border, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => FavoritePage(favoriteItems: [])),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 18),
//         child: Column(
//           children: [
//             DashboardBox(
//               height: 170,
//               content: ImageSlideshow(
//                 userData: widget.userData,
//                 phoneNumber: widget.phoneNumber,
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 10.0,
//                   mainAxisSpacing: 30.0,
//                   childAspectRatio: 1 / 1.2,
//                 ),
//                 itemCount: 6,
//                 itemBuilder: (context, index) {
//                   List<String> imagePaths = [
//                     'assets/shop2.webp',
//                     'assets/machines.webp',
//                     'assets/Agricultural Land.webp',
//                     'assets/Labor.jpeg',
//                     'assets/cattle.jpg',
//                     'assets/addatiimage3.jpg',
//                   ];
//                   List<String> labels = [
//                     tr('Traders'),
//                     tr('Machinery'),
//                     tr('Land'),
//                     tr('Labours'),
//                     tr('Cattle'),
//                     tr('Crops'),
//                   ];

//                   return DashboardCard(
//                     imageUrl: imagePaths[index],
//                     label: labels[index],
//                     onTap: () {
//                       // Navigate based on index
//                       if (index == 0) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => MarketPage(
//                               userData: widget.userData,
//                               phoneNumber: widget.phoneNumber,
//                             ),
//                           ),
//                         );
//                       } else if (index == 1) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => MachineryPage()),
//                         );
//                       } else if (index == 2) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => LandPage()),
//                         );
//                       } else if (index == 3) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LabourRequestPage(
//                               userData: widget.userData,
//                               phoneNumber: widget.phoneNumber,
//                             ),
//                           ),
//                         );
//                       } else if (index == 4) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => CattlePage()),
//                         );
//                       } else if (index == 5) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => CropsPage()),
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             backgroundColor: Color(0xFF00AD83),
//             selectedItemColor: Colors.white,
//             unselectedItemColor: Colors.white,
//             currentIndex: _selectedIndex,
//             onTap: _onItemTapped,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: tr('Home'),
//               ),
//               BottomNavigationBarItem(
//                 icon: SizedBox.shrink(), // We'll put the big ADD button above
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.business_sharp),
//                 label: tr('Market'),
//               ),
//             ],
//           ),
//           // The floating Add button
//           Positioned(
//             top: -24,
//             left: MediaQuery.of(context).size.width / 2 - 30,
//             child: GestureDetector(
//               onTap: () => _onItemTapped(1),
//               child: Column(
//                 children: [
//                   Container(
//                     height: 50,
//                     width: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 8,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.add,
//                       size: 31,
//                       color: Color(0xFF00AD83),
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     tr('Buy/Sell'),
//                     style: TextStyle(fontSize: 13.5, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Reusable card widget
// class DashboardCard extends StatelessWidget {
//   final String imageUrl;
//   final String label;
//   final VoidCallback? onTap;

//   DashboardCard({required this.imageUrl, required this.label, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 280,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: Offset(3, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               flex: 7,
//               child: Padding(
//                 padding: EdgeInsets.all(3.0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Image.asset(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 3,
//               child: Container(
//                 alignment: Alignment.center,
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Simple container for the top slideshow
// class DashboardBox extends StatelessWidget {
//   final double height;
//   final Widget content;
//   DashboardBox({required this.height, required this.content});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       child: content,
//     );
//   }
// }

// class ImageSlideshow extends StatelessWidget {
//   final Map<String, dynamic> userData;
//   final String phoneNumber;
//   ImageSlideshow({required this.userData, required this.phoneNumber});

//   final List<String> imageUrls = [
//     'assets/image2.2.jpg',
//     'assets/image1.webp',
//     'assets/scrolimage3.jpg',
//     'assets/image3.jpg',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // Using any carousel widget, e.g., CarouselSlider from carousel_slider
//     return CarouselSlider(
//       options: CarouselOptions(
//         height: 125,
//         autoPlay: true,
//         enlargeCenterPage: true,
//         viewportFraction: 1.0,
//       ),
//       items: imageUrls.asMap().entries.map((entry) {
//         int index = entry.key;
//         String url = entry.value;

//         return Builder(
//           builder: (BuildContext context) {
//             return GestureDetector(
//               onTap: () {
//                 // Example navigation logic
//                 if (index == 0) {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => MandiRatesPage()));
//                 } else if (index == 1) {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherPage(userData: userData, phoneNumber: phoneNumber)));
//                 }
//               },
//               child: Stack(
//                 children: [
//                   Container(
//                     width: MediaQuery.of(context).size.width,
//                     decoration: BoxDecoration(
//                       color: Colors.grey,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.asset(
//                         url,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   if (index == 0)
//                     Positioned(
//                       bottom: 10,
//                       left: 10,
//                       right: 10,
//                       child: Container(
//                         color: Colors.black.withOpacity(0.5),
//                         padding: EdgeInsets.symmetric(vertical: 5),
//                         child: Text(
//                           'Click here to see Mandi Rates',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
//                         ),
//                       ),
//                     ),
//                   if (index == 1)
//                     Positioned(
//                       bottom: 10,
//                       left: 10,
//                       right: 10,
//                       child: Container(
//                         color: Colors.black.withOpacity(0.5),
//                         padding: EdgeInsets.symmetric(vertical: 5),
//                         child: Text(
//                           'Click here to view Weather Info',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
// }
