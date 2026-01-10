class ReviewResponse {
  final bool success;
  final int count;
  final List<Review> reviews;

  ReviewResponse({
    required this.success,
    required this.count,
    required this.reviews,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Review {
  final String id;
  final ReviewUser user;
  final String vendorId;
  final String materialId;

  // ✅ NGN amounts (original quote)
  final double materialTotalCost;
  final double workmanshipTotalCost;
  final double totalCost;
  final double amountPaid;
  final double amountToPay;

  // ✅ USD amounts (original quote - only for international vendors)
  final double materialTotalCostUSD;
  final double workmanshipTotalCostUSD;
  final double totalCostUSD;
  final double amountPaidUSD;
  final double amountToPayUSD;

  // 🔥 NEW: Final negotiated amounts (when offer is accepted)
  final double? finalMaterialCost;
  final double? finalWorkmanshipCost;
  final double? finalTotalCost;
  final double? finalMaterialCostUSD;
  final double? finalWorkmanshipCostUSD;
  final double? finalTotalCostUSD;

  // ✅ Currency metadata
  final double exchangeRate;
  final bool isInternationalVendor;

  final DateTime deliveryDate;
  final DateTime reminderDate;
  final String comment;
  final String status;
  final bool hasAcceptedOffer;
  final String? acceptedOfferId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.user,
    required this.vendorId,
    required this.materialId,
    required this.materialTotalCost,
    required this.workmanshipTotalCost,
    required this.totalCost,
    required this.amountPaid,
    required this.amountToPay,
    this.materialTotalCostUSD = 0.0,
    this.workmanshipTotalCostUSD = 0.0,
    this.totalCostUSD = 0.0,
    this.amountPaidUSD = 0.0,
    this.amountToPayUSD = 0.0,
    // 🔥 NEW: Final amounts
    this.finalMaterialCost,
    this.finalWorkmanshipCost,
    this.finalTotalCost,
    this.finalMaterialCostUSD,
    this.finalWorkmanshipCostUSD,
    this.finalTotalCostUSD,
    this.exchangeRate = 0.0,
    this.isInternationalVendor = false,
    required this.deliveryDate,
    required this.reminderDate,
    required this.comment,
    required this.status,
    required this.hasAcceptedOffer,
    this.acceptedOfferId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // ✅ Helper to safely parse numeric values as double
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // ✅ Helper to safely parse nullable numeric values
    double? _parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Review(
      id: json['_id'] ?? '',
      user: ReviewUser.fromJson(json['userId']),
      vendorId: json['vendorId'] ?? '',
      materialId: json['materialId'] ?? '',

      // ✅ NGN amounts (original)
      materialTotalCost: _parseDouble(json['materialTotalCost']),
      workmanshipTotalCost: _parseDouble(json['workmanshipTotalCost']),
      totalCost: _parseDouble(json['totalCost']),
      amountPaid: _parseDouble(json['amountPaid']),
      amountToPay: _parseDouble(json['amountToPay']),

      // ✅ USD amounts (original)
      materialTotalCostUSD: _parseDouble(json['materialTotalCostUSD']),
      workmanshipTotalCostUSD: _parseDouble(json['workmanshipTotalCostUSD']),
      totalCostUSD: _parseDouble(json['totalCostUSD']),
      amountPaidUSD: _parseDouble(json['amountPaidUSD']),
      amountToPayUSD: _parseDouble(json['amountToPayUSD']),

      // 🔥 NEW: Final negotiated amounts
      finalMaterialCost: _parseNullableDouble(json['finalMaterialCost']),
      finalWorkmanshipCost: _parseNullableDouble(json['finalWorkmanshipCost']),
      finalTotalCost: _parseNullableDouble(json['finalTotalCost']),
      finalMaterialCostUSD: _parseNullableDouble(json['finalMaterialCostUSD']),
      finalWorkmanshipCostUSD: _parseNullableDouble(
        json['finalWorkmanshipCostUSD'],
      ),
      finalTotalCostUSD: _parseNullableDouble(json['finalTotalCostUSD']),

      // ✅ Currency metadata
      exchangeRate: _parseDouble(json['exchangeRate']),
      isInternationalVendor: json['isInternationalVendor'] ?? false,

      deliveryDate:
          DateTime.tryParse(json['deliveryDate'] ?? '') ?? DateTime.now(),
      reminderDate:
          DateTime.tryParse(json['reminderDate'] ?? '') ?? DateTime.now(),
      comment: json['comment'] ?? '',
      status: json['status'] ?? '',
      hasAcceptedOffer: json['hasAcceptedOffer'] ?? false,
      acceptedOfferId: json['acceptedOfferId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ReviewUser {
  final String id;
  final String fullName;
  final String email;
  final String? address;
  final String? phoneNumber;
  final String? country;

  ReviewUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.address,
    this.phoneNumber,
    this.country,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      country: json['country'],
    );
  }
}

// class ReviewResponse {

//   final bool success;
//   final int count;
//   final List<Review> reviews;

//   ReviewResponse({
//     required this.success,
//     required this.count,
//     required this.reviews,
//   });

//   factory ReviewResponse.fromJson(Map<String, dynamic> json) {
//     return ReviewResponse(
//       success: json['success'] ?? false,
//       count: json['count'] ?? 0,
//       reviews:
//           (json['reviews'] as List<dynamic>?)
//               ?.map((e) => Review.fromJson(e))
//               .toList() ??
//           [],
//     );
//   }
// }

// class Review {
//   final String id;
//   final ReviewUser user;
//   final String vendorId;
//   final String materialId;

//   // ✅ NGN amounts (always present)
//   final double materialTotalCost;
//   final double workmanshipTotalCost;
//   final double totalCost;
//   final double amountPaid;
//   final double amountToPay;

//   // ✅ USD amounts (only for international vendors)
//   final double materialTotalCostUSD;
//   final double workmanshipTotalCostUSD;
//   final double totalCostUSD;
//   final double amountPaidUSD;
//   final double amountToPayUSD;

//   // ✅ Currency metadata
//   final double exchangeRate;
//   final bool isInternationalVendor;

//   final DateTime deliveryDate;
//   final DateTime reminderDate;
//   final String comment;
//   final String status;
//   final bool hasAcceptedOffer;
//   final String? acceptedOfferId;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Review({
//     required this.id,
//     required this.user,
//     required this.vendorId,
//     required this.materialId,
//     required this.materialTotalCost,
//     required this.workmanshipTotalCost,
//     required this.totalCost,
//     required this.amountPaid,
//     required this.amountToPay,
//     this.materialTotalCostUSD = 0.0,
//     this.workmanshipTotalCostUSD = 0.0,
//     this.totalCostUSD = 0.0,
//     this.amountPaidUSD = 0.0,
//     this.amountToPayUSD = 0.0,
//     this.exchangeRate = 0.0,
//     this.isInternationalVendor = false,
//     required this.deliveryDate,
//     required this.reminderDate,
//     required this.comment,
//     required this.status,
//     required this.hasAcceptedOffer,
//     this.acceptedOfferId,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Review.fromJson(Map<String, dynamic> json) {
//     // ✅ Helper to safely parse numeric values as double
//     double _parseDouble(dynamic value) {
//       if (value == null) return 0.0;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? 0.0;
//       return 0.0;
//     }

//     return Review(
//       id: json['_id'] ?? '',
//       user: ReviewUser.fromJson(json['userId']),
//       vendorId: json['vendorId'] ?? '',
//       materialId: json['materialId'] ?? '',

//       // ✅ NGN amounts
//       materialTotalCost: _parseDouble(json['materialTotalCost']),
//       workmanshipTotalCost: _parseDouble(json['workmanshipTotalCost']),
//       totalCost: _parseDouble(json['totalCost']),
//       amountPaid: _parseDouble(json['amountPaid']),
//       amountToPay: _parseDouble(json['amountToPay']),

//       // ✅ USD amounts (from backend)
//       materialTotalCostUSD: _parseDouble(json['materialTotalCostUSD']),
//       workmanshipTotalCostUSD: _parseDouble(json['workmanshipTotalCostUSD']),
//       totalCostUSD: _parseDouble(json['totalCostUSD']),
//       amountPaidUSD: _parseDouble(json['amountPaidUSD']),
//       amountToPayUSD: _parseDouble(json['amountToPayUSD']),

//       // ✅ Currency metadata
//       exchangeRate: _parseDouble(json['exchangeRate']),
//       isInternationalVendor: json['isInternationalVendor'] ?? false,

//       deliveryDate:
//           DateTime.tryParse(json['deliveryDate'] ?? '') ?? DateTime.now(),
//       reminderDate:
//           DateTime.tryParse(json['reminderDate'] ?? '') ?? DateTime.now(),
//       comment: json['comment'] ?? '',
//       status: json['status'] ?? '',
//       hasAcceptedOffer: json['hasAcceptedOffer'] ?? false,
//       acceptedOfferId: json['acceptedOfferId'],
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//     );
//   }
// }

// class ReviewUser {
//   final String id;
//   final String fullName;
//   final String email;
//   final String? address;
//   final String? phoneNumber;
//   final String? country; // ✅ Added for Stripe payment detection

//   ReviewUser({
//     required this.id,
//     required this.fullName,
//     required this.email,
//     this.address,
//     this.phoneNumber,
//     this.country,
//   });

//   factory ReviewUser.fromJson(Map<String, dynamic> json) {
//     return ReviewUser(
//       id: json['_id'] ?? '',
//       fullName: json['fullName'] ?? '',
//       email: json['email'] ?? '',
//       address: json['address'],
//       phoneNumber: json['phoneNumber'],
//       country: json['country'],
//     );
//   }
// }
