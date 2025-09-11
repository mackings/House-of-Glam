class MaterialResponse {
  final bool success;
  final String message;
  final MaterialData? data;

  MaterialResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MaterialResponse.fromJson(Map<String, dynamic> json) {
    return MaterialResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? MaterialData.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class MaterialData {
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
  final String specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaterialData({
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
    required this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialData.fromJson(Map<String, dynamic> json) {
    return MaterialData(
      id: json["_id"] ?? "",
      userId: json["userId"] ?? "",
      categoryId: json["categoryId"] ?? "",
      attireType: json["attireType"] ?? "",
      clothMaterial: json["clothMaterial"] ?? "",
      color: json["color"] ?? "",
      brand: json["brand"] ?? "",
      measurement: (json["measurement"] as List<dynamic>?)
              ?.map((m) => Measurement.fromJson(m))
              .toList() ??
          [],
      sampleImage: List<String>.from(json["sampleImage"] ?? []),
      settlement: json["settlement"] ?? 0,
      isDelivered: json["isDelivered"] ?? false,
      specialInstructions: json["specialInstructions"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "userId": userId,
      "categoryId": categoryId,
      "attireType": attireType,
      "clothMaterial": clothMaterial,
      "color": color,
      "brand": brand,
      "measurement": measurement.map((m) => m.toJson()).toList(),
      "sampleImage": sampleImage,
      "settlement": settlement,
      "isDelivered": isDelivered,
      "specialInstructions": specialInstructions,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class Measurement {
  final int chest;
  final int waist;
  final int hip;
  final int length;
  final int shoulder;
  final int armLength;
  final String armType;
  final int aroundArm;
  final int wrist;
  final int collarFront;
  final int collarBack;

  Measurement({
    required this.chest,
    required this.waist,
    required this.hip,
    required this.length,
    required this.shoulder,
    required this.armLength,
    required this.armType,
    required this.aroundArm,
    required this.wrist,
    required this.collarFront,
    required this.collarBack,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      chest: json["chest"] ?? 0,
      waist: json["waist"] ?? 0,
      hip: json["hip"] ?? 0,
      length: json["length"] ?? 0,
      shoulder: json["shoulder"] ?? 0,
      armLength: json["armLength"] ?? 0,
      armType: json["armType"] ?? "",
      aroundArm: json["aroundArm"] ?? 0,
      wrist: json["wrist"] ?? 0,
      collarFront: json["collarFront"] ?? 0,
      collarBack: json["collarBack"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chest": chest,
      "waist": waist,
      "hip": hip,
      "length": length,
      "shoulder": shoulder,
      "armLength": armLength,
      "armType": armType,
      "aroundArm": aroundArm,
      "wrist": wrist,
      "collarFront": collarFront,
      "collarBack": collarBack,
    };
  }
}
