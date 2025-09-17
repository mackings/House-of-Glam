class TailorPublishedResponse {
  final bool success;
  final String message;
  final List<TailorPublished> data;
  final int count;

  TailorPublishedResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.count,
  });

  factory TailorPublishedResponse.fromJson(Map<String, dynamic> json) {
    return TailorPublishedResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TailorPublished.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TailorPublished {
  final String id;
  final TailorUser? user;
  final String categoryId;
  final String attireType;
  final String clothPublished;
  final String color;
  final String brand;
  final List<String> sampleImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  TailorPublished({
    required this.id,
    required this.user,
    required this.categoryId,
    required this.attireType,
    required this.clothPublished,
    required this.color,
    required this.brand,
    required this.sampleImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TailorPublished.fromJson(Map<String, dynamic> json) {
    return TailorPublished(
      id: json['_id'] ?? '',
      user: json['userId'] != null ? TailorUser.fromJson(json['userId']) : null,
      categoryId: json['categoryId'] ?? '',
      attireType: json['attireType'] ?? '',
      clothPublished: json['clothPublished'] ?? '',
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      sampleImage:
          (json['sampleImage'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class TailorUser {
  final String id;
  final String fullName;
  final String? image;
  final String? address;

  TailorUser({
    required this.id,
    required this.fullName,
    this.image,
    this.address,
  });

  factory TailorUser.fromJson(Map<String, dynamic> json) {
    return TailorUser(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      image: json['image'],
      address: json['address'],
    );
  }
}
