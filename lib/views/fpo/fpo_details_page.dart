import 'package:flutter/material.dart';

class FPODetailsPage extends StatelessWidget {
  final String title;
  final String image;

  const FPODetailsPage({
    Key? key,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> fertilizers = [
      {
        "name": "Iffco",
        "price": "₹266",
        "image": "assets/iffxo.webp"
      },
      {
        "name": "Jai Kisan Urea",
        "price": "₹1350",
        "image": "assets/jai.webp"
      },
      {
        "name": "Emate",
        "price": "₹1700",
        "image": "assets/emate.webp"
      },
      {
        "name": "Tata Metri",
        "price": "₹1200",
        "image": "assets/tata.webp"
      },
      {
        "name": "Curecron",
        "price": "₹800",
        "image": "assets/cuc.webp"
      },
      {
        "name": "ProClaim",
        "price": "₹800",
        "image": "assets/pro.webp"
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          // ✅ TOP BANNER
          Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: Image.asset(
                  image,
                  fit: BoxFit.scaleDown,
                ),
              ),

              // overlay
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // title on image
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // back button
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ✅ LIST OF FERTILIZERS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: fertilizers.length,
              itemBuilder: (context, index) {
                final item = fertilizers[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        Color.fromARGB(215, 223, 241, 223),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item["image"]!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(item["name"]!),
                    subtitle: Text(item["price"]!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}