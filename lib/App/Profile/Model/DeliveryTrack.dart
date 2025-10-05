class MarketTrackingRecord {
  final String id;
  final String trackingNumber;
  final bool isDelivered;
  final double amount;
  final String status;
  final String reference;
  final DateTime createdAt;
  final UserData user;
  final UserData vendor;

  MarketTrackingRecord({
    required this.id,
    required this.trackingNumber,
    required this.isDelivered,
    required this.amount,
    required this.status,
    required this.reference,
    required this.createdAt,
    required this.user,
    required this.vendor,
  });

  factory MarketTrackingRecord.fromJson(Map<String, dynamic> json) {
    return MarketTrackingRecord(
      id: json['_id'],
      trackingNumber: json['trackingNumber'].toString(),
      isDelivered: json['isDelivered'] ?? false,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      reference: json['reference'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      user: UserData.fromJson(json['userId']),
      vendor: UserData.fromJson(json['vendorId']),
    );
  }
}

class UserData {
  final String id;
  final String fullName;
  final String address;

  UserData({
    required this.id,
    required this.fullName,
    required this.address,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'],
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
