class Machine {
  final String name;
  final String model;
  final String price;
  final String detail;
  final String category;
  final String type;
  final String imagePath;

  Machine({
    required this.name,
    required this.model,
    required this.price,
    required this.detail,
    required this.category,
    required this.type,
    required this.imagePath,
  });
}

final List<Machine> dummyMachines = [
  // Tractors
  Machine(
    name: 'Mini Tractor',
    model: 'Mahindra JIVO 245 DI',
    price: '₹4.8 - 5.6 Lakh',
    detail: 'Compact 24 HP mini tractor, ideal for small farms, orchards & narrow rows. Fuel efficient with 4WD option.',
    category: 'Tractors',
    type: 'Mini Tractor',
    imagePath: 'assets/marketing/Mahindra JIVO 245 DI.jpg',
  ),
  Machine(
    name: 'Utility Tractor',
    model: 'Swaraj 855 FE',
    price: '₹8.4 - 8.9 Lakh',
    detail: 'Popular 52 HP utility tractor, great for tillage, transport & haulage. Reliable engine & high resale value.',
    category: 'Tractors',
    type: 'Utility Tractor',
    imagePath: 'assets/marketing/Swaraj 855 FE.jpg',
  ),
  Machine(
    name: '4WD Tractor',
    model: 'Mahindra Arjun Novo 605 DI',
    price: '₹7.6 - 8.2 Lakh',
    detail: 'Powerful 60 HP 4WD model for wet & tough terrain. Advanced hydraulics & comfortable seating.',
    category: 'Tractors',
    type: '4WD Tractor',
    imagePath: 'assets/marketing/Mahindra Arjun Novo 605 DI.jpg',
  ),

  // Harvesters
  Machine(
    name: 'Combine Harvester',
    model: 'Preet 987',
    price: '₹18 - 22 Lakh',
    detail: 'Multi-crop self-propelled combine with 100+ HP. High grain tank capacity & efficient threshing.',
    category: 'Harvesters',
    type: 'Combine Harvester',
    imagePath: 'assets/marketing/Preet 987.jpg',
  ),
  Machine(
    name: 'Paddy Harvester',
    model: 'Kartar 4000 Deluxe',
    price: '₹28 - 32 Lakh',
    detail: 'Heavy-duty paddy & wheat harvester, 120+ HP, large 2000L tank, low fuel consumption.',
    category: 'Harvesters',
    type: 'Paddy Harvester',
    imagePath: 'assets/marketing/Kartar 4000 Deluxe.jpg',
  ),
  Machine(
    name: 'Sugarcane Harvester',
    model: 'John Deere CH570',
    price: '₹35 - 45 Lakh',
    detail: 'Specialized sugarcane machine with high-speed cutting & cleaning. Reduces manual labor significantly.',
    category: 'Harvesters',
    type: 'Sugarcane Harvester',
    imagePath: 'assets/marketing/John Deere CH570.jpg',
  ),

  // Implements
  Machine(
    name: 'Plough',
    model: 'Fieldking Reversible Mouldboard',
    price: '₹85,000 - 1.2 Lakh',
    detail: 'Hydraulic reversible plough for primary tillage. Works well in hard soil, reduces turnaround time.',
    category: 'Implements',
    type: 'Plough',
    imagePath: 'assets/marketing/Fieldking Reversible Mouldboard.jpg',
  ),
  Machine(
    name: 'Rotavator',
    model: 'Shaktiman Champion 7 ft',
    price: '₹1.15 - 1.45 Lakh',
    detail: 'Multi-speed 7 ft rotavator for seedbed preparation. Strong blades & compatible with 45–60 HP tractors.',
    category: 'Implements',
    type: 'Rotavator',
    imagePath: 'assets/marketing/Shaktiman Champion 7 ft.jpg',
  ),
  Machine(
    name: 'Seeder',
    model: 'Mahindra Seed Drill',
    price: '₹90,000 - 1.3 Lakh',
    detail: 'Precision seed cum fertilizer drill. Ensures uniform spacing & depth for better germination.',
    category: 'Implements',
    type: 'Seeder',
    imagePath: 'assets/marketing/Mahindra Seed Drill.jpg',
  ),

  // Irrigation
  Machine(
    name: 'Drip Irrigation',
    model: 'Jain J-Turbo',
    price: '₹12,000 - 45,000 per acre',
    detail: 'Water-saving drip system with pressure-compensating drippers. Ideal for row crops & orchards.',
    category: 'Irrigation',
    type: 'Drip Irrigation',
    imagePath: 'assets/marketing/Jain J-Turbo.jpg',
  ),
  Machine(
    name: 'Sprinkler System',
    model: 'Rain Bird Impact',
    price: '₹25,000 - 80,000 per set',
    detail: 'Full-circle sprinkler for uniform coverage. Suitable for field crops & lawns, easy installation.',
    category: 'Irrigation',
    type: 'Sprinkler System',
    imagePath: 'assets/marketing/Rain Bird Impact.jpg',
  ),
  Machine(
    name: 'Water Pumps',
    model: 'Kirloskar Submersible 5 HP',
    price: '₹18,000 - 35,000',
    detail: 'High-efficiency borewell pump for deep water lifting. Low power consumption & durable.',
    category: 'Irrigation',
    type: 'Water Pumps',
    imagePath: 'assets/marketing/Kirloskar Submersible 5 HP.jpg',
  ),

  // Transport
  Machine(
    name: 'Trailer',
    model: 'Mahindra Trolley 10x6',
    price: '₹2.2 - 3.5 Lakh',
    detail: 'Hydraulic tipping trailer for farm produce transport. Strong frame & high load capacity.',
    category: 'Transport',
    type: 'Trailer',
    imagePath: 'assets/marketing/Mahindra Trolley 10x6.jpg',
  ),
  Machine(
    name: 'Trolley',
    model: 'Swaraj Farm Trolley',
    price: '₹1.8 - 2.8 Lakh',
    detail: 'Multi-purpose tipping trolley. Used for carrying crops, manure & construction material.',
    category: 'Transport',
    type: 'Trolley',
    imagePath: 'assets/marketing/Swaraj Farm Trolley.jpg',
  ),
  Machine(
    name: 'Mini Truck',
    model: 'Mahindra Supro Profit Truck',
    price: '₹5.5 - 7.2 Lakh',
    detail: 'Small commercial vehicle for rural transport. Good mileage & payload for vegetables/fruits.',
    category: 'Transport',
    type: 'Mini Truck',
    imagePath: 'assets/marketing/Mahindra Supro Profit Truck.jpg',
  ),
];
