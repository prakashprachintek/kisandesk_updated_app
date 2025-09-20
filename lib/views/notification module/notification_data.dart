class NotificationData {
  final String title;
  final String body;
  final String reqId;
  final String machineryType;
  final String workType;
  final String workDate;
  final String description;
  final String workInQuantity;
  final String farmerName; 
  final String phone;
  bool read;
  final DateTime createdAt;

  NotificationData({
    required this.title,
    required this.body,
    required this.reqId,
    required this.machineryType,
    required this.workType,
    required this.workDate,
    required this.description,
    required this.workInQuantity,
    required this.farmerName,
    required this.phone,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      reqId: map['reqId'] ?? '',
      machineryType: map['machineryType'] ?? '',
      workType: map['workType'] ?? '',
      workDate: map['workDate'] ?? '',
      description: map['description'] ?? '',
      workInQuantity: map['workInQuantity'] ?? '',
      farmerName: map['farmerName'] ?? '',
      phone: map['phone'] ?? '',
      read: map['read'] ?? false,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'reqId': reqId,
      'machineryType': machineryType,
      'workType': workType,
      'workDate': workDate,
      'description': description,
      'workInQuantity': workInQuantity,
      'farmerName': farmerName,
      'phone': phone,
      'read': read,
      'created_at': createdAt.toIso8601String(),
    };
  }
}