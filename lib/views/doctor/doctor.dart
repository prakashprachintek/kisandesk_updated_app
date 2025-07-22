class Doctor {
  final String fullname;
  final String imageUrl;
  final String phone;
  final String address;
  final String taluka;
  final String district;
  final String village;
  final String gender;
  final String status;

  Doctor({
    required this.fullname,
    required this.imageUrl,
    required this.phone,
    required this.address,
    required this.taluka,
    required this.district,
    required this.village,
    required this.gender,
    required this.status,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      fullname: json['full_name'] ?? '',
      imageUrl: json['image'] ?? '', // your placeholder
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      taluka: json['taluka'] ?? '',
      district: json['district'] ?? '',
      village: json['village'] ?? '',
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
