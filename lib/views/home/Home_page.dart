// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:mainproject1/Labors_page.dart';
// import 'package:mainproject1/Land_page.dart';
// import 'package:mainproject1/mypost.dart';
// import 'package:mainproject1/tabpage.dart';
// import 'LabourRequest.dart';
// import 'favoritePage.dart';
// import 'profile_page.dart';
// import 'Mraket_page1.dart';
// import 'Pesticides_Page.dart';
// import 'Machinery_Page.dart';
// import 'Cattle_Page.dart';
// import 'FarmerRegiste_rPage.dart';
// import 'add_page.dart';
// import 'FarmerPage.dart';
// import 'login_page.dart';
// import 'TransactionPage.dart';
// import 'package:http/http.dart' as http;
// import 'labors_page2.dart';
//
// class HomePage extends StatefulWidget {
//   final Map<String, dynamic> userData;
//   final String phoneNumber;
//   HomePage({required this.phoneNumber,required this.userData});
//
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//
//   // Fetch user data using the phone number
//   Future<Map<String, dynamic>?> fetchUserData(String phoneNumber) async {
//     final url = Uri.parse('http://3.110.121.159/api/user/get_user_by_phone');
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"phoneNumber": phoneNumber.trim()}),
//     );
//
//     print("Server response: ${response.body}"); // Debug line
//
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       print("Decoded Response: $responseData"); // Debug line
//
//       if (responseData['status'] == 'success') {
//         return responseData['results'];
//       } else {
//         print("Status is not success: ${responseData['status']}"); // Debug line
//         return null;
//       }
//     } else {
//       print("Error: ${response.statusCode}"); // Debug line for status code
//       return null;
//     }
//   }
//
//   // Handle profile avatar tap to fetch and show user data
//   void _handleProfileTap() async {
//     final userData = await fetchUserData(widget.phoneNumber);
//     if (userData != null) {
//       print("User Data Loaded: $userData"); // Debug line to verify user data
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ProfilePage(userData: userData, phoneNumber: '',),
//         ),
//       );
//     } else {
//       print("Failed to load user data"); // Debug line for failure
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(tr('failed_to_load_user_data'))),
//       );
//     }
//   }
//
//   void _onItemTapped(int index) async {
//     setState(() {
//       _selectedIndex = index;
//     });
//
//     if (index == 2) {
//       final userData = await fetchUserData(widget.phoneNumber);
//       if (userData != null) {
//         print("User Data Loaded: $userData"); // Debug line to verify user data
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TabbedPage(userData: userData,phoneNumber:widget.phoneNumber,),
//           ),
//         );
//       } else {
//         print("Failed to load user data"); // Debug line for failure
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(tr('failed_to_load_user_data'))),
//         );
//       }
//     } else if (index == 1) {// Handle Add button tap
//       // Fetch user data before navigating to AddPage
//       final userData = await fetchUserData(widget.phoneNumber);
//       if (userData != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AddMarketPostPage(userData: userData, phoneNumber:widget.phoneNumber,),
//           ),
//         );
//       } else {
//         print("Failed to load user data for AddPage");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(tr('failed_to_load_user_data'))),
//         );
//       }
//     }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color(0xFF00AD83),
//           leading: GestureDetector(
//             onTap: _handleProfileTap, // Call the profile API when tapped
//             child: Container(
//               width: 30,
//               height: 30,
//               child: CircleAvatar(
//                 backgroundImage: AssetImage('assets/profile.jpg'),
//                 radius: 15,
//               ),
//             ),
//           ),
//           title: Text(
//             'Farmer Tech Store', // Company name
//             style: TextStyle(
//               color: Colors.white, // Text color
//               fontSize: 16.0, // Font size
//               fontWeight: FontWeight.bold, // Font weight
//             ),
//           ),
//           actions: [
//             DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 icon: Text(
//                   'A+',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18, // Adjust font size as needed
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 items: <String>[
//                   'Kannada',
//                   'English',
//                   'Hindi',
//                   'Marathi',
//                 ].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   if (newValue == 'logout') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginPage()),
//                     );
//                   }
//                 },
//               ),
//             ),
//             IconButton(
//               icon: Icon(Icons.favorite_border, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => FavoritePage(favoriteItems: [],)),
//                 );
//               },
//             ),
//
//           ],
//         ),
//
//         body: Padding(
//           padding: const EdgeInsets.only(left:18,right: 18 ),
//           child: Column(
//             children: [
//               DashboardBox(
//                 height: 170,
//                 content: ImageSlideshow(),
//               ),
//               SizedBox(height: 10),
//               Expanded(
//                 child:GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10.0,
//                     mainAxisSpacing: 30.0,
//                     childAspectRatio: 1 / 1.2,  // Adjust aspect ratio to ensure correct display
//                   ),
//                   itemCount: 6,
//                   itemBuilder: (context, index) {
//                     List<String> imagePaths = [
//                       'assets/shop2.webp',
//                       'assets/machines.webp',
//                       // 'assets/pesticide.webp',
//                       'assets/Agricultural Land.webp',
//                       'assets/Labor.jpeg',
//                       'assets/cattle.jpg',
//                       'assets/addatiimage3.jpg',
//                     ];
//
//                     List<String> labels = [
//                       tr('Adati'),
//                       tr('Machinery'),
//                       // tr('Pesticides'),
//                       tr('Land'),
//                       tr('Labour'),
//                       tr('Cattle'),
//                       tr('farmer'),
//                     ];
//
//                     return DashboardCard(
//                       imageUrl: imagePaths[index],
//                       label: labels[index],
//                       onTap: index == 0
//                           ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => MarketPage(userData:widget.userData,phoneNumber:widget.phoneNumber)),
//                         );
//                       }
//                           : index == 1
//                           ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => MachineryPage()),
//                         );
//                       }
//                       //     : index == 2
//                       //     ? () {
//                       //   Navigator.push(
//                       //     context,
//                       //     MaterialPageRoute(builder: (context) => PesticidesPage()),
//                       //   );
//                       // }
//                           : index == 2
//                           ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => LandPage()),
//                         );
//                       }
//                           : index == 3
//                           ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => LabourRequestPage()),
//                         );
//                       }
//                           : index == 4
//                           ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => CattlePage()
//                           ),
//                         );
//                       }
//                           : index == 5
//                           ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => CropsPage()),
//                         );
//                       }
//                           : null,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               backgroundColor: Color(0xFF00AD83),
//               selectedItemColor: Colors.white,
//               unselectedItemColor: Colors.white,
//               currentIndex: _selectedIndex,
//               onTap: _onItemTapped,
//               items: <BottomNavigationBarItem>[
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: tr('Home'),
//                 ),
//                 BottomNavigationBarItem(
//                   icon: SizedBox.shrink(), // Empty icon for Buy/Sell (replaced with Stack)
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.business_sharp),
//                   label: tr('Market'
//                       ''
//                       ''
//                       ''),
//                 ),
//               ],
//             ),
//             Positioned(
//               top: -24, // Elevates the button out of the navigation bar
//               left: MediaQuery.of(context).size.width / 2 - 30, // Centers the button
//               child: GestureDetector(
//                 onTap: () => _onItemTapped(1), // Handle tap for Buy/Sell
//                 child: Column(
//                   children: [
//                     Container(
//                       height: 50, // Size of the circular button
//                       width: 50,
//                       decoration: BoxDecoration(
//                         color: Colors.white, // Highlight color
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 8,
//                             offset: Offset(0, 3), // Shadow below the button
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.add,
//                         size: 31, // Icon size
//                         color: Color(0xFF00AD83), // Icon color
//                       ),
//                     ),
//                     SizedBox(height: 4), // Space between icon and label
//                     Text(
//                       tr('Buy/Sell'),
//                       style: TextStyle(
//                         fontSize: 13.5,
//                         color: Colors.white, // Label color
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         )
//     );
//   }
// }
//
// class DashboardCard extends StatelessWidget {
//   final String imageUrl;
//   final String label;
//   final VoidCallback? onTap;
//
//   DashboardCard({required this.imageUrl, required this.label, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 280,  // Explicit height for the card
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: Offset(3, 3), // position of the shadow
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               flex: 7,  // Flex for controlling the image height
//               child: Padding(
//                 padding: const EdgeInsets.all(3.0), // Padding around the image
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Image.asset(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity, // Image will fill the available height
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 3,  // Flex for controlling the label height
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
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
//
// class DashboardBox extends StatelessWidget {
//   final double height;
//   final Widget content;
//
//   DashboardBox({required this.height, required this.content});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       child: content,
//     );
//   }
// }
//
// class ImageSlideshow extends StatelessWidget {
//   final List<String> imageUrls = [
//     'assets/image2.2.jpg',
//     'assets/image1.webp',
//     'assets/scrolimage3.jpg',
//     'assets/image3.jpg',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return CarouselSlider(
//       options: CarouselOptions(
//         height: 125,
//         autoPlay: true,
//         enlargeCenterPage: true,
//         viewportFraction: 1.0,
//       ),
//       items: imageUrls.map((url) {
//         return Builder(
//           builder: (BuildContext context) {
//             return Container(
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.asset(
//                   url,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
// }