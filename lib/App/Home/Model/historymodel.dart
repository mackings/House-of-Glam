class MaterialReviewResponse {
  final bool success;
  final int count;
  final List<MaterialReview> materials;

  MaterialReviewResponse({
    required this.success,
    required this.count,
    required this.materials,
  });

  factory MaterialReviewResponse.fromJson(Map<String, dynamic> json) {
    return MaterialReviewResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      materials:
          (json['materials'] as List<dynamic>)
              .map((m) => MaterialReview.fromJson(m))
              .toList(),
    );
  }
}

class MaterialReview {
  final String id;
  final String userId;
  final String categoryId;
  final String attireType;
  final String clothMaterial;
  final String color;
  final String brand;
  final List<Measurement> measurement;
  final List<String> sampleImage;
  final int settlement;
  final bool isDelivered;
  final String? specialInstructions;
  final String createdAt;
  final String updatedAt;

  MaterialReview({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.attireType,
    required this.clothMaterial,
    required this.color,
    required this.brand,
    required this.measurement,
    required this.sampleImage,
    required this.settlement,
    required this.isDelivered,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialReview.fromJson(Map<String, dynamic> json) {
    return MaterialReview(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      attireType: json['attireType'] ?? '',
      clothMaterial: json['clothMaterial'] ?? '',
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      measurement:
          (json['measurement'] as List<dynamic>)
              .map((m) => Measurement.fromJson(m))
              .toList(),
      sampleImage:
          (json['sampleImage'] as List<dynamic>)
              .map((i) => i.toString())
              .toList(),
      settlement: json['settlement'] ?? 0,
      isDelivered: json['isDelivered'] ?? false,
      specialInstructions: json['specialInstructions'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Measurement {
  final int? neck;
  final int? shoulder;
  final int? chest;
  final int? waist;
  final int? hip;
  final int? length;
  final int? armLength;
  final int? sleeveLength;
  final int? aroundArm;
  final int? wrist;
  final int? collarFront;
  final int? collarBack;
  final String? armType;

  Measurement({
    this.neck,
    this.shoulder,
    this.chest,
    this.waist,
    this.hip,
    this.length,
    this.armLength,
    this.sleeveLength,
    this.aroundArm,
    this.wrist,
    this.collarFront,
    this.collarBack,
    this.armType,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      neck: json['neck'],
      shoulder: json['shoulder'],
      chest: json['chest'],
      waist: json['waist'],
      hip: json['hip'],
      length: json['length'],
      armLength: json['armlength'] ?? json['armLength'],
      sleeveLength: json['sleevelength'] ?? json['sleeveLength'],
      aroundArm: json['aroundarm'] ?? json['aroundArm'],
      wrist: json['wrist'],
      collarFront: json['collarfront'] ?? json['collarFront'],
      collarBack: json['collarback'] ?? json['collarBack'],
      armType: json['armType'],
    );
  }
}
