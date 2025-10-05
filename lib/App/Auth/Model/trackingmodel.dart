class TrackingResponse {
  final bool success;
  final String message;
  final List<TrackingRecord> data;

  TrackingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TrackingResponse.fromJson(Map<String, dynamic> json) {
    return TrackingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TrackingRecord.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TrackingRecord {
  final String id;
  final String userId;
  final String vendorId;
  final MaterialInfo material;
  final int trackingNumber;
  final bool isDelivered;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrackingRecord({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.material,
    required this.trackingNumber,
    required this.isDelivered,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrackingRecord.fromJson(Map<String, dynamic> json) {
    return TrackingRecord(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      material: MaterialInfo.fromJson(json['materialId']),
      trackingNumber: json['trackingNumber'] ?? 0,
      isDelivered: json['isDelivered'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class MaterialInfo {
  final String id;
  final String attireType;
  final String clothMaterial;
  final String color;
  final String brand;
  final List<Measurement> measurements;
  final List<String> sampleImages;

  MaterialInfo({
    required this.id,
    required this.attireType,
    required this.clothMaterial,
    required this.color,
    required this.brand,
    required this.measurements,
    required this.sampleImages,
  });

  factory MaterialInfo.fromJson(Map<String, dynamic> json) {
    return MaterialInfo(
      id: json['_id'] ?? '',
      attireType: json['attireType'] ?? '',
      clothMaterial: json['clothMaterial'] ?? '',
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      measurements:
          (json['measurement'] as List<dynamic>?)
              ?.map((e) => Measurement.fromJson(e))
              .toList() ??
          [],
      sampleImages:
          (json['sampleImage'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class Measurement {
  final int neck;
  final int shoulder;
  final int chest;
  final int waist;
  final int hip;
  final int sleevelength;
  final int armlength;
  final int aroundarm;
  final int wrist;
  final int collarfront;
  final int collarback;
  final int length;
  final String armType;

  Measurement({
    required this.neck,
    required this.shoulder,
    required this.chest,
    required this.waist,
    required this.hip,
    required this.sleevelength,
    required this.armlength,
    required this.aroundarm,
    required this.wrist,
    required this.collarfront,
    required this.collarback,
    required this.length,
    required this.armType,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      neck: json['neck'] ?? 0,
      shoulder: json['shoulder'] ?? 0,
      chest: json['chest'] ?? 0,
      waist: json['waist'] ?? 0,
      hip: json['hip'] ?? 0,
      sleevelength: json['sleevelength'] ?? 0,
      armlength: json['armlength'] ?? 0,
      aroundarm: json['aroundarm'] ?? 0,
      wrist: json['wrist'] ?? 0,
      collarfront: json['collarfront'] ?? 0,
      collarback: json['collarback'] ?? 0,
      length: json['length'] ?? 0,
      armType: json['armType'] ?? '',
    );
  }
}
