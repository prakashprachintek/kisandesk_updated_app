import 'package:flutter/material.dart';

class WomenLaborersPage extends StatelessWidget {
  final List<Map<String, String>> laborers = [
    {
      'name': 'John Doe',
      'image': 'assets/slider2.webp',
      'details': 'Experienced laborer in construction and farming.'
    },
    {
      'name': 'Mike Smith',
      'image': 'assets/men_labour.PNG',
      'details': 'Tractor driver with 5 years of experience.'
    },
    {
      'name': 'David Johnson',
      'image': 'assets/slider2.webp',
      'details': 'Specialized in irrigation and soil management.'
    },
    {
      'name': 'David Johnson',
      'image': 'assets/slider2.webp',
      'details': 'Specialized in irrigation and soil management.'
    },
    {
      'name': 'David Johnson',
      'image': 'assets/men_labour.PNG',
      'details': 'Specialized in irrigation and soil management.'
    },
    {
      'name': 'David Johnson',
      'image': 'assets/men_labour.PNG',
      'details': 'Specialized in irrigation and soil management.'
    },
    // Add more laborers here
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: 10, // Spacing between columns
          mainAxisSpacing: 10, // Spacing between rows
          childAspectRatio: 0.8, // Adjust the size ratio between the image and text
        ),
        itemCount: laborers.length,
        itemBuilder: (context, index) {
          final laborer = laborers[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(laborer['image']!),
                ),
                SizedBox(height: 10),
                Text(
                  laborer['name']!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    laborer['details']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
