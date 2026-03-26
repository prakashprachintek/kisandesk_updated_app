import 'package:flutter/material.dart';
import 'package:mainproject1/views/marketing/dummy_model.dart';

class ShowroomMachinesPage extends StatefulWidget {
  const ShowroomMachinesPage({super.key});

  @override
  State<ShowroomMachinesPage> createState() => _ShowroomMachinesPageState();
}

class _ShowroomMachinesPageState extends State<ShowroomMachinesPage> {
  String selectedCategory = '';
  String selectedMachineType = '';

  final List<String> categories = [
    'All Showrooms',
    'Tractors',
    'Harvesters',
    'Implements',
    'Irrigation',
    'Transport',
  ];

  final Map<String, List<String>> machineTypes = {
    'Tractors': [
      'Mini Tractor',
      'Utility Tractor',
      'Row Crop Tractor',
      '4WD Tractor',
    ],
    'Harvesters': [
      'Combine Harvester',
      'Paddy Harvester',
      'Sugarcane Harvester',
    ],
    'Implements': [
      'Plough',
      'Rotavator',
      'Seeder',
      'Sprayer',
    ],
    'Irrigation': [
      'Drip Irrigation',
      'Sprinkler System',
      'Water Pumps',
    ],
    'Transport': [
      'Trailer',
      'Trolley',
      'Mini Truck',
    ],
  };

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category == 'All Showrooms' ? '' : category;
      selectedMachineType = '';
    });
  }

  void _selectMachineType(String type) {
    setState(() {
      selectedMachineType = selectedMachineType == type ? '' : type;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter machines based on selections
    final filteredMachines = dummyMachines.where((machine) {
      final categoryMatch =
          selectedCategory.isEmpty || machine.category == selectedCategory;
      final typeMatch =
          selectedMachineType.isEmpty || machine.type == selectedMachineType;
      return categoryMatch && typeMatch;
    }).toList();

    final currentMachineTypes = machineTypes[selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Showrooms & Machines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/NewLogo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category chips
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Machine Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: categories.map((category) {
                    final isSelected = selectedCategory == category ||
                        (category == 'All Showrooms' &&
                            selectedCategory.isEmpty);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.green.shade700,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => _selectCategory(category),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Type chips (only show if category selected has types)
              if (currentMachineTypes.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Machine Types',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: currentMachineTypes.map((type) {
                      final isSelected = selectedMachineType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (_) => _selectMachineType(type),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              // Selected filters summary
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Showing: ${selectedCategory.isEmpty ? 'All Showrooms' : selectedCategory}'
                  '${selectedMachineType.isNotEmpty ? ' → $selectedMachineType' : ''}\n'
                  '(${filteredMachines.length} machines found)',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

              // Machines list
              Expanded(
                child: filteredMachines.isEmpty
                    ? const Center(
                        child: Text(
                          'No machines match your selection',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredMachines.length,
                        itemBuilder: (context, index) {
                          final machine = filteredMachines[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image placeholder (add real assets later)
                                // Replace this entire Container(...) block:
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.asset(
                                    machine.imagePath,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(Icons.broken_image,
                                              size: 60, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${machine.name} - ${machine.model}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        machine.price,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        machine.detail,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
