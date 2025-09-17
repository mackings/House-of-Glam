import 'dart:convert';

class TailorAssignedMaterialsResponse {
  final bool success;
  final int count;
  final List<TailorAssignedMaterial> reviews;

  TailorAssignedMaterialsResponse({
    required this.success,
    required this.count,
    required this.reviews,
  });

  factory TailorAssignedMaterialsResponse.fromJson(Map<String, dynamic> json) {
    return TailorAssignedMaterialsResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      reviews:
          (json['reviews'] as List<dynamic>? ?? [])
              .map((item) => TailorAssignedMaterial.fromJson(item))
              .toList(),
    );
  }
}

class TailorAssignedMaterial {
  final String id;
  final User user;
  final Vendor vendor;
  final MaterialItem material;
  final int materialTotalCost;
  final int workmanshipTotalCost;
  final int totalCost;
  final int? amountPaid;
  final int? amountToPay;
  final DateTime? deliveryDate;
  final DateTime? reminderDate;
  final String? comment;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TailorAssignedMaterial({
    required this.id,
    required this.user,
    required this.vendor,
    required this.material,
    required this.materialTotalCost,
    required this.workmanshipTotalCost,
    required this.totalCost,
    this.amountPaid,
    this.amountToPay,
    this.deliveryDate,
    this.reminderDate,
    this.comment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TailorAssignedMaterial.fromJson(Map<String, dynamic> json) {
    return TailorAssignedMaterial(
      id: json['_id'] ?? '',
      user: User.fromJson(json['userId'] ?? {}),
      vendor: Vendor.fromJson(json['vendorId'] ?? {}),
      material: MaterialItem.fromJson(json['materialId'] ?? {}),
      materialTotalCost: json['materialTotalCost'] ?? 0,
      workmanshipTotalCost: json['workmanshipTotalCost'] ?? 0,
      totalCost: json['totalCost'] ?? 0,
      amountPaid: json['amountPaid'],
      amountToPay: json['amountToPay'],
      deliveryDate:
          json['deliveryDate'] != null
              ? DateTime.tryParse(json['deliveryDate'])
              : null,
      reminderDate:
          json['reminderDate'] != null
              ? DateTime.tryParse(json['reminderDate'])
              : null,
      comment: json['comment'],
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String? image;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
    );
  }
}

class Vendor {
  final String id;
  final String userId;
  final String businessName;
  final String businessEmail;
  final String businessPhone;

  Vendor({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessEmail,
    required this.businessPhone,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      businessName: json['businessName'] ?? '',
      businessEmail: json['businessEmail'] ?? '',
      businessPhone: json['businessPhone'] ?? '',
    );
  }
}

class MaterialItem {
  final String id;
  final String attireType;
  final String clothMaterial;
  final String color;
  final String brand;
  final List<String> sampleImages;
  final bool isDelivered;

  MaterialItem({
    required this.id,
    required this.attireType,
    required this.clothMaterial,
    required this.color,
    required this.brand,
    required this.sampleImages,
    required this.isDelivered,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['_id'] ?? '',
      attireType: json['attireType'] ?? '',
      clothMaterial: json['clothMaterial'] ?? '',
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      sampleImages: List<String>.from(json['sampleImage'] ?? []),
      isDelivered: json['isDelivered'] ?? false,
    );
  }
}
