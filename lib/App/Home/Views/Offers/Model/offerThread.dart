import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================================
// OFFER THREAD MODELS (for list view)
// ============================================================================

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
      data:
          (json['data'] as List<dynamic>?)
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
      chats:
          (json['chats'] as List<dynamic>?)
              ?.map((e) => OfferChat.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      chatSummary: ChatSummary.fromJson(json['chatSummary']),
    );
  }
}

// ============================================================================
// MAKE OFFER MODELS (for detail view - ADD THIS SECTION)
// ============================================================================

class MakeOfferResponse {
  final bool success;
  final String message;
  final MakeOffer data;

  MakeOfferResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MakeOfferResponse.fromJson(Map<String, dynamic> json) {
    return MakeOfferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: MakeOffer.fromJson(json['data'] ?? {}),
    );
  }
}

class MakeOffer {
  final String id;
  final User user;
  final Vendor vendor;
  final MaterialItem material;
  final Review review;
  final String status;

  // Consent tracking
  final bool buyerConsent;
  final bool vendorConsent;
  final bool mutualConsentAchieved;

  // Final agreed amounts (NGN)
  final double finalMaterialCost;
  final double finalWorkmanshipCost;
  final double finalTotalCost;

  // Final agreed amounts (USD)
  final double finalMaterialCostUSD;
  final double finalWorkmanshipCostUSD;
  final double finalTotalCostUSD;

  // Currency information
  final bool isInternationalVendor;
  final double exchangeRate;
  final String buyerCountry;
  final String vendorCountry;

  // Chat history
  final List<OfferChat> chats;

  final DateTime createdAt;
  final DateTime updatedAt;

  MakeOffer({
    required this.id,
    required this.user,
    required this.vendor,
    required this.material,
    required this.review,
    required this.status,
    this.buyerConsent = false,
    this.vendorConsent = false,
    this.mutualConsentAchieved = false,
    this.finalMaterialCost = 0.0,
    this.finalWorkmanshipCost = 0.0,
    this.finalTotalCost = 0.0,
    this.finalMaterialCostUSD = 0.0,
    this.finalWorkmanshipCostUSD = 0.0,
    this.finalTotalCostUSD = 0.0,
    this.isInternationalVendor = false,
    this.exchangeRate = 0.0,
    this.buyerCountry = 'Nigeria',
    this.vendorCountry = 'Nigeria',
    required this.chats,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MakeOffer.fromJson(Map<String, dynamic> json) {
    return MakeOffer(
      id: json['_id'] ?? '',
      user: User.fromJson(json['userId'] ?? {}),
      vendor: Vendor.fromJson(json['vendorId'] ?? {}),
      material: MaterialItem.fromJson(json['materialId'] ?? {}),
      review: Review.fromJson(json['reviewId'] ?? {}),
      status: json['status'] ?? 'pending',

      // Consent
      buyerConsent: json['buyerConsent'] ?? false,
      vendorConsent: json['vendorConsent'] ?? false,
      mutualConsentAchieved: json['mutualConsentAchieved'] ?? false,

      // Final amounts NGN
      finalMaterialCost: (json['finalMaterialCost'] ?? 0).toDouble(),
      finalWorkmanshipCost: (json['finalWorkmanshipCost'] ?? 0).toDouble(),
      finalTotalCost: (json['finalTotalCost'] ?? 0).toDouble(),

      // Final amounts USD
      finalMaterialCostUSD: (json['finalMaterialCostUSD'] ?? 0).toDouble(),
      finalWorkmanshipCostUSD:
          (json['finalWorkmanshipCostUSD'] ?? 0).toDouble(),
      finalTotalCostUSD: (json['finalTotalCostUSD'] ?? 0).toDouble(),

      // Currency info
      isInternationalVendor: json['isInternationalVendor'] ?? false,
      exchangeRate: (json['exchangeRate'] ?? 0).toDouble(),
      buyerCountry: json['buyerCountry'] ?? 'Nigeria',
      vendorCountry: json['vendorCountry'] ?? 'Nigeria',

      // Chats
      chats:
          (json['chats'] as List<dynamic>?)
              ?.map((e) => OfferChat.fromJson(e))
              .toList() ??
          [],

      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Helper getters for UI logic
  OfferChat? get latestChat => chats.isNotEmpty ? chats.last : null;

  bool get buyerCanRespond {
    if (chats.isEmpty) return false;
    final lastChat = chats.last;
    return lastChat.senderType == 'vendor' && !mutualConsentAchieved;
  }

  bool get vendorCanRespond {
    if (chats.isEmpty) return true;
    final lastChat = chats.last;
    return lastChat.senderType == 'customer' && !mutualConsentAchieved;
  }

  bool get isWaitingForBuyerConsent {
    return vendorConsent && !buyerConsent && !mutualConsentAchieved;
  }

  bool get isWaitingForVendorConsent {
    return buyerConsent && !vendorConsent && !mutualConsentAchieved;
  }
}

// ============================================================================
// SHARED MODELS (used by both OfferThread and MakeOffer)
// ============================================================================

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
      vendorUser: User.fromJson(json['userId'] ?? {}),
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
  final double materialTotalCost;
  final double workmanshipTotalCost;
  final double totalCost;
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
      materialTotalCost: (json['materialTotalCost'] ?? 0).toDouble(),
      workmanshipTotalCost: (json['workmanshipTotalCost'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}

class OfferChat {
  final String id;
  final String senderType; // "customer" or "vendor"
  final String action; // "incoming", "countered", "accepted", "rejected"

  // NGN amounts (always present)
  final double counterMaterialCost;
  final double counterWorkmanshipCost;
  final double counterTotalCost;

  // USD amounts (for international vendors)
  final double counterMaterialCostUSD;
  final double counterWorkmanshipCostUSD;
  final double counterTotalCostUSD;

  final String comment;
  final DateTime timestamp;

  OfferChat({
    required this.id,
    required this.senderType,
    required this.action,
    required this.counterMaterialCost,
    required this.counterWorkmanshipCost,
    required this.counterTotalCost,
    required this.counterMaterialCostUSD,
    required this.counterWorkmanshipCostUSD,
    required this.counterTotalCostUSD,
    required this.comment,
    required this.timestamp,
  });

  factory OfferChat.fromJson(Map<String, dynamic> json) {
    return OfferChat(
      id: json['_id'] ?? '',
      senderType: json['senderType'] ?? '',
      action: json['action'] ?? '',
      // NGN amounts
      counterMaterialCost: (json['counterMaterialCost'] ?? 0).toDouble(),
      counterWorkmanshipCost: (json['counterWorkmanshipCost'] ?? 0).toDouble(),
      counterTotalCost: (json['counterTotalCost'] ?? 0).toDouble(),
      // USD amounts
      counterMaterialCostUSD: (json['counterMaterialCostUSD'] ?? 0).toDouble(),
      counterWorkmanshipCostUSD:
          (json['counterWorkmanshipCostUSD'] ?? 0).toDouble(),
      counterTotalCostUSD: (json['counterTotalCostUSD'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderType': senderType,
      'action': action,
      'counterMaterialCost': counterMaterialCost,
      'counterWorkmanshipCost': counterWorkmanshipCost,
      'counterTotalCost': counterTotalCost,
      'counterMaterialCostUSD': counterMaterialCostUSD,
      'counterWorkmanshipCostUSD': counterWorkmanshipCostUSD,
      'counterTotalCostUSD': counterTotalCostUSD,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Helper getters
  bool get showAmounts => action != 'rejected';

  String get actionLabel {
    switch (action) {
      case 'incoming':
        return 'Initial Offer';
      case 'countered':
        return 'Counter Offer';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return action;
    }
  }

  Color get actionBadgeColor {
    switch (action) {
      case 'incoming':
        return const Color(0xFF3B82F6);
      case 'countered':
        return const Color(0xFFF59E0B);
      case 'accepted':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  // Copy with method for easy updates
  OfferChat copyWith({
    String? id,
    String? senderType,
    String? action,
    double? counterMaterialCost,
    double? counterWorkmanshipCost,
    double? counterTotalCost,
    double? counterMaterialCostUSD,
    double? counterWorkmanshipCostUSD,
    double? counterTotalCostUSD,
    String? comment,
    DateTime? timestamp,
  }) {
    return OfferChat(
      id: id ?? this.id,
      senderType: senderType ?? this.senderType,
      action: action ?? this.action,
      counterMaterialCost: counterMaterialCost ?? this.counterMaterialCost,
      counterWorkmanshipCost:
          counterWorkmanshipCost ?? this.counterWorkmanshipCost,
      counterTotalCost: counterTotalCost ?? this.counterTotalCost,
      counterMaterialCostUSD:
          counterMaterialCostUSD ?? this.counterMaterialCostUSD,
      counterWorkmanshipCostUSD:
          counterWorkmanshipCostUSD ?? this.counterWorkmanshipCostUSD,
      counterTotalCostUSD: counterTotalCostUSD ?? this.counterTotalCostUSD,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'OfferChat(id: $id, senderType: $senderType, action: $action, '
        'NGN: $counterTotalCost, USD: $counterTotalCostUSD, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfferChat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ChatSummary {
  final int totalMessages;
  final OfferChat latestMessage;

  ChatSummary({required this.totalMessages, required this.latestMessage});

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      totalMessages: json['totalMessages'] ?? 0,
      latestMessage: OfferChat.fromJson(json['latestMessage']),
    );
  }
}

// class OfferThreadResponse {
//   final bool success;
//   final String message;
//   final int count;
//   final List<OfferThread> data;

//   OfferThreadResponse({
//     required this.success,
//     required this.message,
//     required this.count,
//     required this.data,
//   });

//   factory OfferThreadResponse.fromJson(Map<String, dynamic> json) {
//     return OfferThreadResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       count: json['count'] ?? 0,
//       data:
//           (json['data'] as List<dynamic>?)
//               ?.map((e) => OfferThread.fromJson(e))
//               .toList() ??
//           [],
//     );
//   }
// }

// class OfferThread {
//   final String id;
//   final User user;
//   final Vendor vendor;
//   final MaterialItem material;
//   final Review review;
//   final String status;
//   final List<OfferChat> chats;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final ChatSummary chatSummary;

//   OfferThread({
//     required this.id,
//     required this.user,
//     required this.vendor,
//     required this.material,
//     required this.review,
//     required this.status,
//     required this.chats,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.chatSummary,
//   });

//   factory OfferThread.fromJson(Map<String, dynamic> json) {
//     return OfferThread(
//       id: json['_id'] ?? '',
//       user: User.fromJson(json['userId']),
//       vendor: Vendor.fromJson(json['vendorId']),
//       material: MaterialItem.fromJson(json['materialId']),
//       review: Review.fromJson(json['reviewId']),
//       status: json['status'] ?? '',
//       chats:
//           (json['chats'] as List<dynamic>?)
//               ?.map((e) => OfferChat.fromJson(e))
//               .toList() ??
//           [],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       chatSummary: ChatSummary.fromJson(json['chatSummary']),
//     );
//   }
// }

// class User {
//   final String id;
//   final String fullName;
//   final String email;
//   final String role;

//   User({
//     required this.id,
//     required this.fullName,
//     required this.email,
//     required this.role,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['_id'] ?? '',
//       fullName: json['fullName'] ?? '',
//       email: json['email'] ?? '',
//       role: json['role'] ?? '',
//     );
//   }
// }

// class Vendor {
//   final String id;
//   final User vendorUser;
//   final String businessName;

//   Vendor({
//     required this.id,
//     required this.vendorUser,
//     required this.businessName,
//   });

//   factory Vendor.fromJson(Map<String, dynamic> json) {
//     return Vendor(
//       id: json['_id'] ?? '',
//       vendorUser: User.fromJson(json['userId']),
//       businessName: json['businessName'] ?? '',
//     );
//   }
// }

// class MaterialItem {
//   final String id;
//   final String clothMaterial;
//   final String attireType;
//   final String color;
//   final String brand;
//   final List<String> sampleImages;

//   MaterialItem({
//     required this.id,
//     required this.clothMaterial,
//     required this.attireType,
//     required this.color,
//     required this.brand,
//     required this.sampleImages,
//   });

//   factory MaterialItem.fromJson(Map<String, dynamic> json) {
//     return MaterialItem(
//       id: json['_id'] ?? '',
//       clothMaterial: json['clothMaterial'] ?? '',
//       attireType: json['attireType'] ?? '',
//       color: json['color'] ?? '',
//       brand: json['brand'] ?? '',
//       sampleImages: List<String>.from(json['sampleImage'] ?? []),
//     );
//   }
// }

// class Review {
//   final String id;
//   final String comment;
//   final int materialTotalCost;
//   final int workmanshipTotalCost;
//   final int totalCost;
//   final String status;

//   Review({
//     required this.id,
//     required this.comment,
//     required this.materialTotalCost,
//     required this.workmanshipTotalCost,
//     required this.totalCost,
//     required this.status,
//   });

//   factory Review.fromJson(Map<String, dynamic> json) {
//     return Review(
//       id: json['_id'] ?? '',
//       comment: json['comment'] ?? '',
//       materialTotalCost: json['materialTotalCost'] ?? 0,
//       workmanshipTotalCost: json['workmanshipTotalCost'] ?? 0,
//       totalCost: json['totalCost'] ?? 0,
//       status: json['status'] ?? '',
//     );
//   }
// }

// class OfferChat {
//   final String id;
//   final String senderType; // "customer" or "vendor"
//   final String action; // "incoming", "countered", "accepted", "rejected"

//   // NGN amounts (always present)
//   final double counterMaterialCost;
//   final double counterWorkmanshipCost;
//   final double counterTotalCost;

//   // USD amounts (for international vendors)
//   final double counterMaterialCostUSD;
//   final double counterWorkmanshipCostUSD;
//   final double counterTotalCostUSD;

//   final String comment;
//   final DateTime timestamp;

//   OfferChat({
//     required this.id,
//     required this.senderType,
//     required this.action,
//     required this.counterMaterialCost,
//     required this.counterWorkmanshipCost,
//     required this.counterTotalCost,
//     required this.counterMaterialCostUSD,
//     required this.counterWorkmanshipCostUSD,
//     required this.counterTotalCostUSD,
//     required this.comment,
//     required this.timestamp,
//   });

//   factory OfferChat.fromJson(Map<String, dynamic> json) {
//     return OfferChat(
//       id: json['_id'] ?? '',
//       senderType: json['senderType'] ?? '',
//       action: json['action'] ?? '',
//       // NGN amounts
//       counterMaterialCost: (json['counterMaterialCost'] ?? 0).toDouble(),
//       counterWorkmanshipCost: (json['counterWorkmanshipCost'] ?? 0).toDouble(),
//       counterTotalCost: (json['counterTotalCost'] ?? 0).toDouble(),
//       // USD amounts
//       counterMaterialCostUSD: (json['counterMaterialCostUSD'] ?? 0).toDouble(),
//       counterWorkmanshipCostUSD: (json['counterWorkmanshipCostUSD'] ?? 0).toDouble(),
//       counterTotalCostUSD: (json['counterTotalCostUSD'] ?? 0).toDouble(),
//       comment: json['comment'] ?? '',
//       timestamp: DateTime.parse(json['timestamp']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'senderType': senderType,
//       'action': action,
//       'counterMaterialCost': counterMaterialCost,
//       'counterWorkmanshipCost': counterWorkmanshipCost,
//       'counterTotalCost': counterTotalCost,
//       'counterMaterialCostUSD': counterMaterialCostUSD,
//       'counterWorkmanshipCostUSD': counterWorkmanshipCostUSD,
//       'counterTotalCostUSD': counterTotalCostUSD,
//       'comment': comment,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }

//   // Helper getters
//   bool get showAmounts => action != 'rejected';

//   String get actionLabel {
//     switch (action) {
//       case 'incoming':
//         return 'Initial Offer';
//       case 'countered':
//         return 'Counter Offer';
//       case 'accepted':
//         return 'Accepted';
//       case 'rejected':
//         return 'Rejected';
//       default:
//         return action;
//     }
//   }

//   Color get actionBadgeColor {
//     switch (action) {
//       case 'incoming':
//         return const Color(0xFF3B82F6);
//       case 'countered':
//         return const Color(0xFFF59E0B);
//       case 'accepted':
//         return const Color(0xFF10B981);
//       case 'rejected':
//         return const Color(0xFFEF4444);
//       default:
//         return Colors.grey;
//     }
//   }

//   // Copy with method for easy updates
//   OfferChat copyWith({
//     String? id,
//     String? senderType,
//     String? action,
//     double? counterMaterialCost,
//     double? counterWorkmanshipCost,
//     double? counterTotalCost,
//     double? counterMaterialCostUSD,
//     double? counterWorkmanshipCostUSD,
//     double? counterTotalCostUSD,
//     String? comment,
//     DateTime? timestamp,
//   }) {
//     return OfferChat(
//       id: id ?? this.id,
//       senderType: senderType ?? this.senderType,
//       action: action ?? this.action,
//       counterMaterialCost: counterMaterialCost ?? this.counterMaterialCost,
//       counterWorkmanshipCost: counterWorkmanshipCost ?? this.counterWorkmanshipCost,
//       counterTotalCost: counterTotalCost ?? this.counterTotalCost,
//       counterMaterialCostUSD: counterMaterialCostUSD ?? this.counterMaterialCostUSD,
//       counterWorkmanshipCostUSD: counterWorkmanshipCostUSD ?? this.counterWorkmanshipCostUSD,
//       counterTotalCostUSD: counterTotalCostUSD ?? this.counterTotalCostUSD,
//       comment: comment ?? this.comment,
//       timestamp: timestamp ?? this.timestamp,
//     );
//   }

//   @override
//   String toString() {
//     return 'OfferChat(id: $id, senderType: $senderType, action: $action, '
//         'NGN: $counterTotalCost, USD: $counterTotalCostUSD, comment: $comment)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is OfferChat && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
// }

// class ChatSummary {
//   final int totalMessages;
//   final OfferChat latestMessage;

//   ChatSummary({required this.totalMessages, required this.latestMessage});

//   factory ChatSummary.fromJson(Map<String, dynamic> json) {
//     return ChatSummary(
//       totalMessages: json['totalMessages'] ?? 0,
//       latestMessage: OfferChat.fromJson(json['latestMessage']),
//     );
//   }
// }
