class TailorMaterialResponse {
  final bool success;
  final String message;
  final List<TailorMaterialItem> data;

  TailorMaterialResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TailorMaterialResponse.fromJson(Map<String, dynamic> json) {
    return TailorMaterialResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => TailorMaterialItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TailorMaterialItem {
  final String id;
  final UserInfo userId;
  final String categoryId;
  final String attireType;
  final String clothMaterial;
  final String color;
  final String brand;
  final List<Measurement> measurement;
  final List<String> sampleImage;
  final int? price;
  final String? deliveryDate;
  final String? reminderDate;
  final String vendorId;
  final int settlement;
  final bool isDelivered;
  final String? specialInstructions;
  final String createdAt;
  final String updatedAt;

  TailorMaterialItem({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.attireType,
    required this.clothMaterial,
    required this.color,
    required this.brand,
    required this.measurement,
    required this.sampleImage,
    this.price,
    this.deliveryDate,
    this.reminderDate,
    required this.vendorId,
    required this.settlement,
    required this.isDelivered,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TailorMaterialItem.fromJson(Map<String, dynamic> json) {
    return TailorMaterialItem(
      id: json['_id'] ?? '',
      userId: json['userId'] != null
          ? UserInfo.fromJson(json['userId'] as Map<String, dynamic>)
          : UserInfo(id: '', fullName: 'Unknown User', email: ''),
      categoryId: json['categoryId'] ?? '',
      attireType: json['attireType'] ?? '',
      clothMaterial: json['clothMaterial'] ?? '',
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      measurement:
          (json['measurement'] as List<dynamic>?)
              ?.map((m) => Measurement.fromJson(m))
              .toList() ??
          [],
      sampleImage:
          (json['sampleImage'] as List<dynamic>?)
              ?.map((img) => img.toString())
              .toList() ??
          [],
      price: json['price'],
      deliveryDate: json['deliveryDate'],
      reminderDate: json['reminderDate'],
      vendorId: json['vendorId'] ?? '',
      settlement: json['settlement'] ?? 0,
      isDelivered: json['isDelivered'] ?? false,
      specialInstructions: json['specialInstructions'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class UserInfo {
  final String id;
  final String fullName;
  final String email;

  UserInfo({required this.id, required this.fullName, required this.email});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Measurement {
  final Map<String, dynamic> values;

  Measurement({required this.values});

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(values: json);
  }
}
