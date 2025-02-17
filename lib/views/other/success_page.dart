// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'FarmerRegiste_rPage.dart';
// import 'Home_page.dart';
//
//
// class SuccessPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: Padding(
//         padding: const EdgeInsets.only(left: 38, right: 38, top: 218),  // Left and right padding
//         child: Column(
//          // mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             CircleAvatar(
//               radius: 40,
//               backgroundColor: Colors.white,
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Color(0xFF00AD83), width: 4),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     Icons.check,
//                     color: Color(0xFF00AD83),
//                     size: 45,
//                   ),
//
//                 ),
//               ),
//             ),
//             SizedBox(height: 15),
//
//             Text(
//               tr('Success'),
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               tr('Congratulations!_You_have_been_successfully_authenticated'),
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18,color: Colors.grey),
//             ),
//
//             SizedBox(height: 72
//             ),
//             SizedBox(
//               width: double.infinity,
//               height: 60,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Navigate to the DashboardPage when the button is pressed
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) =>SuccessPage ()),
//                   );
//                 },
//                 child: Text(
//                   tr('Continue'),
//                   style: TextStyle(fontSize: 16, color: Colors.white),),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF00AD83), // Green button color
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(32),
//                   ),
//                 ),
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
