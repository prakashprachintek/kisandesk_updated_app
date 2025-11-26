// lib/models/address_model.dart
class Address {
  final String id;
  final String fullName;
  final String phone;
  final String houseDetails;
  final String village;
  final String taluka;
  final String district;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.houseDetails,
    required this.village,
    required this.taluka,
    required this.district,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'houseDetails': houseDetails,
        'village': village,
        'taluka': taluka,
        'district': district,
        'state': state,
        'pincode': pincode,
        'isDefault': isDefault,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'],
        fullName: json['fullName'],
        phone: json['phone'],
        houseDetails: json['houseDetails'],
        village: json['village'],
        taluka: json['taluka'],
        district: json['district'],
        state: json['state'],
        pincode: json['pincode'],
        isDefault: json['isDefault'] ?? false,
      );

  Address copyWith({bool? isDefault}) => Address(
        id: id,
        fullName: fullName,
        phone: phone,
        houseDetails: houseDetails,
        village: village,
        taluka: taluka,
        district: district,
        state: state,
        pincode: pincode,
        isDefault: isDefault ?? this.isDefault,
      );

  String get fullAddress =>
      [houseDetails, village, taluka, district, state, pincode]
          .where((s) => s.isNotEmpty)
          .join(', ');
}