import 'dart:convert';
import 'package:http/http.dart' as http;

class MandiRate {
  final String market;
  final String commodity;
  final String minPrice;
  final String maxPrice;

  MandiRate({
    required this.market,
    required this.commodity,
    required this.minPrice,
    required this.maxPrice,
  });

  factory MandiRate.fromJson(Map<String, dynamic> json) {
    return MandiRate(
      market: json['Market'] ?? 'N/A',
      commodity: json['Commodity'] ?? 'N/A',
      minPrice: json['Min_Price'] ?? 'N/A',
      maxPrice: json['Max_Price'] ?? 'N/A',
    );
  }
}

Future<List<MandiRate>> fetchTopMandiRates() async {
  final String apiUrl =
      'https://api.data.gov.in/resource/35985678-0d79-46b4-9ed6-6f13308a1d24?format=json&filters%5BArrival_Date%5D=20/01/2025&api-key=579b464db66ec23bdd00000193cd44da4f644b886d3a756d44d8bbfe&limit=10';

  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List records = data['records'];
    return records
        .map((json) => MandiRate.fromJson(json))
        .take(4) // just first 4 for carousel
        .toList();
  } else {
    throw Exception('Failed to load mandi rates');
  }
}
