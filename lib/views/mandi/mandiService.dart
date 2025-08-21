import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

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
      '${KD.api}/admin/fetch_mandi_rates';


  final response = await http.post(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List records = data['results'];
    return records
        .map((json) => MandiRate.fromJson(json))
        .take(10) // just first 10 for carousel
        .toList();
  } else {
    throw Exception('Failed to load mandi rates');
  }
}
