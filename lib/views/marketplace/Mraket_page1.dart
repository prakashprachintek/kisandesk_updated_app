import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../home/home_page2.dart';
import '../machinery/TraderDetailsPage.dart';
import '../other/add_page.dart';
import '../other/tabpage.dart';

class MarketPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  MarketPage({required this.phoneNumber, required this.userData});

  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int _selectedIndex = 0;
  List<dynamic> traders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTraders(); // Fetch traders on page load
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>TabbedPage(userData: widget.userData,phoneNumber:widget.phoneNumber,)),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(phoneNumber: widget.phoneNumber, userData: widget.userData),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMarketPostPage(userData: widget.userData,
              phoneNumber: widget.phoneNumber,
            isUserExists: true,
          ),
        ),
      );
    }
  }



  Future<void> fetchTraders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://3.110.121.159/api/admin/get_traders');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          traders = data['results']; // Update the traders list with the results array
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load traders');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching traders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AD83),
        title: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 40.0,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search, color: Color(0xFF00AD83)),
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(19),
                borderSide: BorderSide(color: Color(0xFF00AD83)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(19),
                borderSide: BorderSide(color: Color(0xFF00AD83)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(19),
                borderSide: BorderSide(color: Color(0xFF00AD83)),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
          children: [
            DashboardBox(
              height: 125,
              content: ImageSlideshow(),
            ),
            SizedBox(height: 22),
            Text(
              'Gulbarga',
              style: TextStyle(color: Color(0xFF00AD83), fontSize: 16),
            ),
            SizedBox(height: 16), // Add spacing after "Gulbarga"
         Expanded(
    child:isLoading
          ? Center(child: CircularProgressIndicator())
          : traders.isEmpty
          ? Center(child: Text('No traders found'))
          : ListView.builder(
        itemCount: traders.length,
        itemBuilder: (context, index) {
          final trader = traders[index];
          return ListTile(
            title: Text(trader['org_name'] ?? 'Unknown Trader'),
            subtitle: Text(trader['address'] ?? 'Unknown Address'),
            trailing: Text(trader['phone_number'] ?? 'Unknown Contact'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TraderDetailsPage(
                    shopName: trader['org_name'],
                    Address: trader['address'],
                    contactDetails: trader['phone_number'],
                    share: 'Share',
                    location: trader['address'],
                    review: 'Great trader!',
                    latitude: 17.367810,  // Latitude of the shop
                    longitude: 76.812670, // Longitude of the shop
                    imageAssets: [
                      'assets/addatiimage3.jpg',
                      'assets/addatiimage1.jpg',
                      'assets/addatiimage4.jpg',
                      'assets/addatiimage2.jpg'
                    ], // Assuming logo is the trader's image
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
        ],
      ),
    ),
        bottomNavigationBar: Stack(
          clipBehavior: Clip.none,
          children: [
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Color(0xFF00AD83),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: tr('Home'),
                ),
                BottomNavigationBarItem(
                  icon: SizedBox.shrink(), // Empty icon for Buy/Sell (replaced with Stack)
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_sharp),
                  label: tr('Market'),
                ),
              ],
            ),
            Positioned(
              top: -24, // Elevates the button out of the navigation bar
              left: MediaQuery.of(context).size.width / 2 - 30, // Centers the button
              child: GestureDetector(
                onTap: () => _onItemTapped(1), // Handle tap for Buy/Sell
                child: Column(
                  children: [
                    Container(
                      height: 50, // Size of the circular button
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white, // Highlight color
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3), // Shadow below the button
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        size: 31, // Icon size
                        color: Color(0xFF00AD83), // Icon color
                      ),
                    ),
                    SizedBox(height: 4), // Space between icon and label
                    Text(
                      tr('Buy/Sell'),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.white, // Label color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}

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
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: content,
//     );
//   }
// }

class ImageSlideshow extends StatelessWidget {
  final List<String> imageUrls = [
    'assets/image2.2.jpg',
    'assets/image1.webp',
    'assets/scrolimage3.jpg',
    'assets/image3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 125,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
      ),
      items: imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// class TraderIcon extends StatelessWidget {
//   final String label;
//
//   TraderIcon({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TraderDetailsPage(
//               shopName: 'Colorful Indian Shop',
//               Address: 'Address: near the city',
//               contactDetails: '123-456-7890',
//               share:'Share',
//               location: 'Puttaparthi, Andhra Pradesh, India',
//               review: 'Great shop with lots of variety!',
//               latitude: 17.367810,  // Latitude of the shop
//               longitude: 76.812670, // Longitude of the shop
//
//               imageAssets: [
//                 'assets/addatiimage3.jpg',
//                 'assets/addatiimage1.jpg',
//                 'assets/addatiimage4.jpg',
//                 'assets/addatiimage2.jpg'
//               ],
//             ),
//           ),
//         );
//
//       },
//       child: Column(
//         children: [
//           Icon(Icons.shop, color: Color(0xFF00AD83)),
//           SizedBox(height: 4),
//           Text(label, style: TextStyle(color: Color(0xFF00AD83))),
//         ],
//       ),
//     );
//   }
// }