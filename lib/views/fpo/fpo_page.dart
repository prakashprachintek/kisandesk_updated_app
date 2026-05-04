import 'package:flutter/material.dart';
import './fpo_details_page.dart';
class FPOPage extends StatelessWidget {
  const FPOPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> fpoList = [
      {
        "title": "Nisarga FPC",
        "address": "Munhalli, Tq, Main Road, Aland, Gulbarga-585302, Karnataka",
        "image": "assets/nisarga.jpg"
      },
      {
        "title": "KisanDesk",
        "address": "Nimbarga, Aland taluka, Gulbarga, Karnataka, India - 585213",
        "image": "assets/Icon3.png"
      },
      {
        "title": "Kshemalingeashwara Agro PCL",
        "address": "H NO. 3-85, VILLAGE NARONA TALUKA ALAND, Gulbarga, Karnataka, India - 585311",
        "image": "assets/agro.webp"
      },
      {
        "title": "Bandalli",
        "address": "Gunj, Gulbarga, Karnataka, India",
        "image": "assets/agro2.webp"
      },
            {
        "title": "BakkamPrabhu",
        "address": "Gunj, Gulbarga, Karnataka, India",
        "image": "assets/agro3.webp"
      },
      
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("FPO's"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fpoList.length,
        itemBuilder: (context, index) {
          final item = fpoList[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FPODetailsPage(
                    title: item["title"]!,
                    image: item["image"]!,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              height: 150,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.white,
                    Color.fromARGB(215, 223, 241, 223),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // TITLE
                          Text(
                            item["title"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ADDRESS
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.red),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item["address"]!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Image.asset(
                        item["image"]!,
                        fit: BoxFit.scaleDown,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
