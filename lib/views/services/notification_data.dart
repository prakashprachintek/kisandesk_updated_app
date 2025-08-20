class NotificationData {
  final String body;
  final String reqId;
  final String machineryType;
  final String workType;
  final String workDate;
  final String description;
  final String workInQuantity;
  final String farmername;
  final String phone;

  NotificationData(
      {required this.body,
      required this.reqId,
      required this.machineryType,
      required this.workType,
      required this.workDate,
      required this.description,
      required this.workInQuantity,
      required this.farmername,
      required this.phone});

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      body: map['body'] ?? '',
      reqId: map['reqId'] ?? '',
      machineryType: map['machineryType'] ?? '',
      workType: map['workType'] ?? '',
      workDate: map['workDate'] ?? '',
      description: map['description'] ?? '',
      workInQuantity: map['workInQuantity'] ?? '',
      farmername: map['farmerName'] ?? '',
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'body': body,
      'reqId': reqId,
      'machineryType': machineryType,
      'workType': workType,
      'workDate': workDate,
      'description': description,
      'workInQuantity': workInQuantity,
      'farmername': farmername,
      'phone': phone
    };
  }
}
