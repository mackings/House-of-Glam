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
  final double materialTotalCost;
  final double workmanshipTotalCost;
  final double totalCost;
  final double? amountPaid;
  final double? amountToPay;
  // USD amounts for international vendors
  final double? materialTotalCostUSD;
  final double? workmanshipTotalCostUSD;
  final double? totalCostUSD;
  final double? amountPaidUSD;
  final double? amountToPayUSD;
  final double? tax;
  final double? commission;
  final double? vendorBaseTotal;
  final double? userPayableTotal;
  final double? designerPayableTotal;
  final double? vendorBaseTotalUSD;
  final double? userPayableTotalUSD;
  final double? designerPayableTotalUSD;
  final bool isInternationalVendor;
  final String? country;
  final DateTime? deliveryDate;
  final DateTime? reminderDate;
  final String? comment;
  final String status;
  final int? trackingNumber;
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
    this.materialTotalCostUSD,
    this.workmanshipTotalCostUSD,
    this.totalCostUSD,
    this.amountPaidUSD,
    this.amountToPayUSD,
    this.tax,
    this.commission,
    this.vendorBaseTotal,
    this.userPayableTotal,
    this.designerPayableTotal,
    this.vendorBaseTotalUSD,
    this.userPayableTotalUSD,
    this.designerPayableTotalUSD,
    this.isInternationalVendor = false,
    this.country,
    this.deliveryDate,
    this.reminderDate,
    this.comment,
    required this.status,
    this.trackingNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TailorAssignedMaterial.fromJson(Map<String, dynamic> json) {
    // ✅ Helper to safely parse numeric values as double
    double parseDoubleNonNull(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    double? parseFirstDouble(Map<String, dynamic> payload, List<String> keys) {
      for (final key in keys) {
        final value = parseDouble(payload[key]);
        if (value != null) return value;
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    int? parseTrackingNumber(Map<String, dynamic> payload) {
      final direct = parseInt(payload['trackingNumber']);
      if (direct != null) return direct;

      final trackingId = payload['trackingId'];
      if (trackingId is Map<String, dynamic>) {
        final nested = parseInt(trackingId['trackingNumber']);
        if (nested != null) return nested;
      }

      final tracking = payload['tracking'];
      if (tracking is Map<String, dynamic>) {
        return parseInt(tracking['trackingNumber']);
      }

      return null;
    }

    return TailorAssignedMaterial(
      id: json['_id'] ?? '',
      user: User.fromJson(json['userId'] ?? {}),
      vendor: Vendor.fromJson(json['vendorId'] ?? {}),
      material: MaterialItem.fromJson(json['materialId'] ?? {}),
      materialTotalCost: parseDoubleNonNull(json['materialTotalCost']),
      workmanshipTotalCost: parseDoubleNonNull(json['workmanshipTotalCost']),
      totalCost: parseDoubleNonNull(json['totalCost']),
      amountPaid: parseDouble(json['amountPaid']),
      amountToPay: parseDouble(json['amountToPay']),
      materialTotalCostUSD: parseDouble(json['materialTotalCostUSD']),
      workmanshipTotalCostUSD: parseDouble(json['workmanshipTotalCostUSD']),
      totalCostUSD: parseDouble(json['totalCostUSD']),
      amountPaidUSD: parseDouble(json['amountPaidUSD']),
      amountToPayUSD: parseDouble(json['amountToPayUSD']),
      tax: parseDouble(json['tax']),
      commission: parseDouble(json['commission']),
      vendorBaseTotal: parseFirstDouble(json, [
        'vendorBaseTotal',
        'payoutBaseAmount',
      ]),
      userPayableTotal: parseFirstDouble(json, ['userPayableTotal']),
      designerPayableTotal: parseFirstDouble(json, [
        'designerPayableTotal',
        'payoutNetAmount',
        'payoutNetToDesigner',
        'tailorPayable',
        'vendorPayableTotal',
        'netToDesigner',
      ]),
      vendorBaseTotalUSD: parseFirstDouble(json, ['vendorBaseTotalUSD']),
      userPayableTotalUSD: parseFirstDouble(json, ['userPayableTotalUSD']),
      designerPayableTotalUSD: parseFirstDouble(json, [
        'designerPayableTotalUSD',
        'payoutNetAmountUSD',
        'payoutNetToDesignerUSD',
        'tailorPayableUSD',
        'vendorPayableTotalUSD',
        'netToDesignerUSD',
      ]),
      isInternationalVendor: json['isInternationalVendor'] ?? false,
      country: json['country'],
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
      trackingNumber: parseTrackingNumber(json),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get normalizedStatus => status.trim().toLowerCase();

  bool get isRequestingStatus => normalizedStatus == 'requesting';

  bool get isPartPaymentStatus => normalizedStatus == 'part payment';

  bool get isFullPaymentStatus {
    const fullySettledStatuses = {
      'full payment',
      'sent for delivery',
      'attire sent for delivery',
      'for delivery',
      'delivery',
      'delivered',
      'delivered attire',
    };
    return fullySettledStatuses.contains(normalizedStatus);
  }

  bool get isSentForDeliveryStatus {
    const sentStatuses = {
      'sent for delivery',
      'attire sent for delivery',
      'for delivery',
      'delivery',
      'delivered',
      'delivered attire',
    };
    return material.isDelivered || sentStatuses.contains(normalizedStatus);
  }

  double get fallbackDisplayTotal {
    final materialCost =
        isInternationalVendor
            ? (materialTotalCostUSD ?? 0.0)
            : materialTotalCost;
    final workmanshipCost =
        isInternationalVendor
            ? (workmanshipTotalCostUSD ?? 0.0)
            : workmanshipTotalCost;
    final explicitTotal =
        isInternationalVendor ? (totalCostUSD ?? 0.0) : totalCost;
    final paid =
        isInternationalVendor ? (amountPaidUSD ?? 0.0) : (amountPaid ?? 0.0);
    final toPay =
        isInternationalVendor ? (amountToPayUSD ?? 0.0) : (amountToPay ?? 0.0);

    if (explicitTotal > 0) return explicitTotal;
    if ((materialCost + workmanshipCost) > 0) {
      return materialCost + workmanshipCost;
    }
    return paid + toPay;
  }

  double get resolvedVendorBaseTotal {
    final explicit =
        isInternationalVendor
            ? (vendorBaseTotalUSD ?? vendorBaseTotal)
            : vendorBaseTotal;
    if (explicit != null && explicit > 0) return explicit;
    return fallbackDisplayTotal;
  }

  double get resolvedDesignerPayableTotal {
    final explicit =
        isInternationalVendor
            ? (designerPayableTotalUSD ?? designerPayableTotal)
            : designerPayableTotal;
    if (explicit != null && explicit > 0) return explicit;

    final baseTotal = resolvedVendorBaseTotal;
    final fee = commission ?? 0.0;
    if (baseTotal > 0 && fee > 0) {
      final net = baseTotal - fee;
      if (net > 0) return net;
    }

    return (baseTotal * 0.90).abs();
  }

  double get resolvedClientPayableTotal {
    final explicit =
        isInternationalVendor
            ? (userPayableTotalUSD ?? userPayableTotal)
            : userPayableTotal;
    if (explicit != null && explicit > 0) {
      return explicit;
    }

    final explicitOutstanding =
        isInternationalVendor ? (amountToPayUSD ?? 0.0) : (amountToPay ?? 0.0);
    final explicitPaid =
        isInternationalVendor ? (amountPaidUSD ?? 0.0) : (amountPaid ?? 0.0);

    if ((explicitPaid + explicitOutstanding) > 0) {
      return explicitPaid + explicitOutstanding;
    }

    return resolvedVendorBaseTotal;
  }

  double get resolvedAmountPaidForUi {
    final explicitPaid =
        isInternationalVendor ? (amountPaidUSD ?? 0.0) : (amountPaid ?? 0.0);
    if (explicitPaid > 0) {
      return explicitPaid;
    }

    if (isFullPaymentStatus) {
      return resolvedClientPayableTotal;
    }

    return 0.0;
  }

  double get resolvedOutstandingForUi {
    final explicitOutstanding =
        isInternationalVendor ? (amountToPayUSD ?? 0.0) : (amountToPay ?? 0.0);
    if (explicitOutstanding > 0) {
      return explicitOutstanding;
    }

    final payableTotal = resolvedClientPayableTotal;
    final paid = resolvedAmountPaidForUi;

    if (isFullPaymentStatus) {
      return 0.0;
    }

    if (payableTotal > paid) {
      return payableTotal - paid;
    }

    return 0.0;
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String? image;
  final String? country;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.image,
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      country: json['country'],
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
