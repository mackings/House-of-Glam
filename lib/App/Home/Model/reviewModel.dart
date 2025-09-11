

class ReviewResponse {
  final bool success;
  final int count;
  final List<Review> reviews;

  ReviewResponse({
    required this.success,
    required this.count,
    required this.reviews,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) => ReviewResponse(
        success: json['success'] ?? false,
        count: json['count'] ?? 0,
        reviews: (json['reviews'] as List<dynamic>?)
                ?.map((e) => Review.fromJson(e))
                .toList() ??
            [],
      );
}

class Review {
  final String id;
  final User user;
  final Vendor vendor;
  final MaterialItem material;
  final double materialTotalCost;
  final double workmanshipTotalCost;
  final double totalCost;
  final DateTime deliveryDate;
  final DateTime reminderDate;
  final String comment;
  final String status;

  Review({
    required this.id,
    required this.user,
    required this.vendor,
    required this.material,
    required this.materialTotalCost,
    required this.workmanshipTotalCost,
    required this.totalCost,
    required this.deliveryDate,
    required this.reminderDate,
    required this.comment,
    required this.status,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['_id'],
        user: User.fromJson(json['userId']),
        vendor: Vendor.fromJson(json['vendorId']),
        material: MaterialItem.fromJson(json['materialId']),
        materialTotalCost: (json['materialTotalCost'] ?? 0).toDouble(),
        workmanshipTotalCost: (json['workmanshipTotalCost'] ?? 0).toDouble(),
        totalCost: (json['totalCost'] ?? 0).toDouble(),
        deliveryDate: DateTime.parse(json['deliveryDate']),
        reminderDate: DateTime.parse(json['reminderDate']),
        comment: json['comment'] ?? '',
        status: json['status'] ?? '',
      );
}

class User {
  final String id;
  final String fullName;
  final String email;

  User({required this.id, required this.fullName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id'],
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
      );
}

class Vendor {
  final String id;
  final String businessName;
  final String businessEmail;
  final String businessPhone;

  Vendor({
    required this.id,
    required this.businessName,
    required this.businessEmail,
    required this.businessPhone,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['_id'],
        businessName: json['businessName'] ?? '',
        businessEmail: json['businessEmail'] ?? '',
        businessPhone: json['businessPhone'] ?? '',
      );
}

class MaterialItem {
  final String id;
  final String attireType;
  final String clothMaterial;
  final String color;
  final String brand;
  final List<Measurement> measurement;
  final List<String> sampleImage;
  final double settlement;
  final bool isDelivered;
  final String? specialInstructions;

  MaterialItem({
    required this.id,
    required this.attireType,
    required this.clothMaterial,
    required this.color,
    required this.brand,
    required this.measurement,
    required this.sampleImage,
    required this.settlement,
    required this.isDelivered,
    this.specialInstructions,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
        id: json['_id'],
        attireType: json['attireType'] ?? '',
        clothMaterial: json['clothMaterial'] ?? '',
        color: json['color'] ?? '',
        brand: json['brand'] ?? '',
        measurement: (json['measurement'] as List<dynamic>?)
                ?.map((e) => Measurement.fromJson(e))
                .toList() ??
            [],
        sampleImage:
            (json['sampleImage'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        settlement: (json['settlement'] ?? 0).toDouble(),
        isDelivered: json['isDelivered'] ?? false,
        specialInstructions: json['specialInstructions'],
      );
}

class Measurement {
  final double neck;
  final double shoulder;
  final double chest;
  final double waist;
  final double hip;
  final double sleeveLength;
  final double armLength;
  final double aroundArm;
  final double wrist;
  final double collarFront;
  final double collarBack;
  final double length;
  final String armType;

  Measurement({
    this.neck = 0,
    this.shoulder = 0,
    this.chest = 0,
    this.waist = 0,
    this.hip = 0,
    this.sleeveLength = 0,
    this.armLength = 0,
    this.aroundArm = 0,
    this.wrist = 0,
    this.collarFront = 0,
    this.collarBack = 0,
    this.length = 0,
    this.armType = '',
  });

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        neck: (json['neck'] ?? 0).toDouble(),
        shoulder: (json['shoulder'] ?? 0).toDouble(),
        chest: (json['chest'] ?? 0).toDouble(),
        waist: (json['waist'] ?? 0).toDouble(),
        hip: (json['hip'] ?? 0).toDouble(),
        sleeveLength: (json['sleevelength'] ?? 0).toDouble(),
        armLength: (json['armlength'] ?? 0).toDouble(),
        aroundArm: (json['aroundarm'] ?? 0).toDouble(),
        wrist: (json['wrist'] ?? 0).toDouble(),
        collarFront: (json['collarfront'] ?? 0).toDouble(),
        collarBack: (json['collarback'] ?? 0).toDouble(),
        length: (json['length'] ?? 0).toDouble(),
        armType: json['armType'] ?? '',
      );
}
