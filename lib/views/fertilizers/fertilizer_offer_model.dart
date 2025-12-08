// lib/views/fertilizers/fertilizer_offer_model.dart
class Offer {
  final String title;
  final String message;
  final String code;
  final String amount;

  Offer({
    required this.title,
    required this.message,
    required this.code,
    required this.amount,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? '',
      amount: json['amount'] ?? '',
    );
  }
}

class OfferResponse {
  final List<Offer> offers;

  OfferResponse({required this.offers});

  factory OfferResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> results = json['results'] ?? [];

    if (results.isEmpty) return OfferResponse(offers: []);

    List<dynamic> offerListJson = results[0]['offers'] ?? [];

    List<Offer> offerList =
        offerListJson.map((i) => Offer.fromJson(i)).toList();

    return OfferResponse(offers: offerList);
  }
}
