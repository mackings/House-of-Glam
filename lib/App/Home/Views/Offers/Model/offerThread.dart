

class OfferThreadResponse {
  final bool success;
  final String message;
  final int count;
  final List<OfferThread> data;

  OfferThreadResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
  });

  factory OfferThreadResponse.fromJson(Map<String, dynamic> json) {
    return OfferThreadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => OfferThread.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OfferThread {
  final String id;
  final User user;
  final Vendor vendor;
  final MaterialItem material;
  final Review review;
  final String status;
  final List<OfferChat> chats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatSummary chatSummary;

  OfferThread({
    required this.id,
    required this.user,
    required this.vendor,
    required this.material,
    required this.review,
    required this.status,
    required this.chats,
    required this.createdAt,
    required this.updatedAt,
    required this.chatSummary,
  });

  factory OfferThread.fromJson(Map<String, dynamic> json) {
    return OfferThread(
      id: json['_id'] ?? '',
      user: User.fromJson(json['userId']),
      vendor: Vendor.fromJson(json['vendorId']),
      material: MaterialItem.fromJson(json['materialId']),
      review: Review.fromJson(json['reviewId']),
      status: json['status'] ?? '',
      chats: (json['chats'] as List<dynamic>?)
              ?.map((e) => OfferChat.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      chatSummary: ChatSummary.fromJson(json['chatSummary']),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class Vendor {
  final String id;
  final User vendorUser;
  final String businessName;

  Vendor({
    required this.id,
    required this.vendorUser,
    required this.businessName,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'] ?? '',
      vendorUser: User.fromJson(json['userId']),
      businessName: json['businessName'] ?? '',
    );
  }
}

class MaterialItem {
  final String id;
  final String clothMaterial;
  final String attireType;
  final String color;
  final String brand;
  final List<String> sampleImages;

  MaterialItem({
    required this.id,
    required this.clothMaterial,
    required this.attireType,
    required this.color,
    required this.brand,
    required this.sampleImages,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['_id'] ?? '',
      clothMaterial: json['clothMaterial'] ?? '',
      attireType: json['attireType'] ?? '',
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      sampleImages: List<String>.from(json['sampleImage'] ?? []),
    );
  }
}

class Review {
  final String id;
  final String comment;
  final int materialTotalCost;
  final int workmanshipTotalCost;
  final int totalCost;
  final String status;

  Review({
    required this.id,
    required this.comment,
    required this.materialTotalCost,
    required this.workmanshipTotalCost,
    required this.totalCost,
    required this.status,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      comment: json['comment'] ?? '',
      materialTotalCost: json['materialTotalCost'] ?? 0,
      workmanshipTotalCost: json['workmanshipTotalCost'] ?? 0,
      totalCost: json['totalCost'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class OfferChat {
  final String id;
  final String senderType; // "customer" or "vendor"
  final String action; // "makeOffered", "countered", etc.
  final int counterMaterialCost;
  final int counterWorkmanshipCost;
  final int counterTotalCost;
  final String comment;
  final DateTime timestamp;

  OfferChat({
    required this.id,
    required this.senderType,
    required this.action,
    required this.counterMaterialCost,
    required this.counterWorkmanshipCost,
    required this.counterTotalCost,
    required this.comment,
    required this.timestamp,
  });

  factory OfferChat.fromJson(Map<String, dynamic> json) {
    return OfferChat(
      id: json['_id'] ?? '',
      senderType: json['senderType'] ?? '',
      action: json['action'] ?? '',
      counterMaterialCost: json['counterMaterialCost'] ?? 0,
      counterWorkmanshipCost: json['counterWorkmanshipCost'] ?? 0,
      counterTotalCost: json['counterTotalCost'] ?? 0,
      comment: json['comment'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatSummary {
  final int totalMessages;
  final OfferChat latestMessage;

  ChatSummary({
    required this.totalMessages,
    required this.latestMessage,
  });

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      totalMessages: json['totalMessages'] ?? 0,
      latestMessage: OfferChat.fromJson(json['latestMessage']),
    );
  }
}
