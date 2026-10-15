class TailorTrackingResponse {
  final bool success;
  final String message;
  final List<TailorTracking> data;

  TailorTrackingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TailorTrackingResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['data'] ?? [];

    // Filter out entries with null materialId
    final filteredList = rawList.where((e) => e['materialId'] != null).toList();

    return TailorTrackingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: filteredList.map((e) => TailorTracking.fromJson(e)).toList(),
    );
  }
}

class TailorTracking {
  final String id;
  final String userId;
  final String vendorId;
  final MaterialDetails material;
  final int trackingNumber;
  final bool isDelivered;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated once a real Fez shipment has been created for this order via
  // POST /tracking/createCarrierShipment. Null for orders dispatched before
  // that existed, or that haven't been shipped yet — the UI falls back to
  // the legacy numeric trackingNumber display in that case.
  final String? carrier;
  final String? carrierTrackingNumber;
  final String? serviceType;

  TailorTracking({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.material,
    required this.trackingNumber,
    required this.isDelivered,
    required this.createdAt,
    required this.updatedAt,
    this.carrier,
    this.carrierTrackingNumber,
    this.serviceType,
  });

  factory TailorTracking.fromJson(Map<String, dynamic> json) {
    return TailorTracking(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      material: MaterialDetails.fromJson(json['materialId']),
      trackingNumber: json['trackingNumber'] ?? 0,
      isDelivered: json['isDelivered'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      carrier: json['carrier']?.toString(),
      carrierTrackingNumber:
          (json['carrierTrackingNumber'] ?? json['waybillNumber'])
              ?.toString(),
      serviceType: json['serviceType']?.toString(),
    );
  }

  bool get hasCarrierShipment =>
      carrier != null &&
      carrier!.isNotEmpty &&
      carrierTrackingNumber != null &&
      carrierTrackingNumber!.isNotEmpty;
}

class MaterialDetails {
  final String id;
  final String attireType;
  final String clothMaterial;
  final String color;
  final String brand;
  final List<String> sampleImage;

  MaterialDetails({
    required this.id,
    required this.attireType,
    required this.clothMaterial,
    required this.color,
    required this.brand,
    required this.sampleImage,
  });

  factory MaterialDetails.fromJson(Map<String, dynamic> json) {
    return MaterialDetails(
      id: json['_id'] ?? '',
      attireType: json['attireType'] ?? '',
      clothMaterial: json['clothMaterial'] ?? '',
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      sampleImage:
          (json['sampleImage'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}
