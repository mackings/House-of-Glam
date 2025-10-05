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
  final int materialTotalCost;
  final int workmanshipTotalCost;
  final int totalCost;
  final int amountPaid; // ✅ new
  final int amountToPay; // ✅ new
  final DateTime deliveryDate;
  final DateTime reminderDate;
  final String comment;
  final String status;
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
    required this.deliveryDate,
    required this.reminderDate,
    required this.comment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      user: ReviewUser.fromJson(json['userId']),
      vendorId: json['vendorId'] ?? '',
      materialId: json['materialId'] ?? '',
      materialTotalCost: json['materialTotalCost'] ?? 0,
      workmanshipTotalCost: json['workmanshipTotalCost'] ?? 0,
      totalCost: json['totalCost'] ?? 0,
      amountPaid: json['amountPaid'] ?? 0,
      amountToPay: json['amountToPay'] ?? 0,
      deliveryDate:
          DateTime.tryParse(json['deliveryDate'] ?? '') ?? DateTime.now(),
      reminderDate:
          DateTime.tryParse(json['reminderDate'] ?? '') ?? DateTime.now(),
      comment: json['comment'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ReviewUser {
  final String id;
  final String fullName;
  final String email;

  ReviewUser({required this.id, required this.fullName, required this.email});

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
