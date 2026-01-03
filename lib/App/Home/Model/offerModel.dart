// import 'dart:ui';

// class MakeOfferResponse {
//   final bool success;
//   final String message;
//   final int count;
//   final List<MakeOffer> offers;

//   MakeOfferResponse({
//     required this.success,
//     required this.message,
//     this.count = 0,
//     required this.offers,
//   });

//   factory MakeOfferResponse.fromJson(Map<String, dynamic> json) {
//     return MakeOfferResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       count: json['count'] ?? 0,
//       offers: (json['data'] as List<dynamic>?)
//               ?.map((e) => MakeOffer.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }

// class MakeOffer {
//   final String id;
//   final OfferUser user;
//   final OfferVendor vendor;
//   final String materialId;
//   final String reviewId;
//   final String status; // pending, accepted, rejected, countered, incoming

//   // ✅ NEW: Mutual consent fields
//   final bool buyerConsent;
//   final bool vendorConsent;
//   final bool mutualConsentAchieved;

//   // ✅ NEW: Final agreed amounts in NGN
//   final double finalMaterialCost;
//   final double finalWorkmanshipCost;
//   final double finalTotalCost;

//   // ✅ NEW: Final agreed amounts in USD (for international)
//   final double finalMaterialCostUSD;
//   final double finalWorkmanshipCostUSD;
//   final double finalTotalCostUSD;

//   // ✅ NEW: Currency/location fields
//   final bool isInternationalVendor;
//   final double exchangeRate;
//   final String buyerCountry;
//   final String vendorCountry;

//   // Legacy field
//   final double total;

//   // WhatsApp-style chat history
//   final List<OfferChat> chats;

//   final DateTime createdAt;
//   final DateTime updatedAt;

//   MakeOffer({
//     required this.id,
//     required this.user,
//     required this.vendor,
//     required this.materialId,
//     required this.reviewId,
//     required this.status,
//     this.buyerConsent = false,
//     this.vendorConsent = false,
//     this.mutualConsentAchieved = false,
//     this.finalMaterialCost = 0.0,
//     this.finalWorkmanshipCost = 0.0,
//     this.finalTotalCost = 0.0,
//     this.finalMaterialCostUSD = 0.0,
//     this.finalWorkmanshipCostUSD = 0.0,
//     this.finalTotalCostUSD = 0.0,
//     this.isInternationalVendor = false,
//     this.exchangeRate = 0.0,
//     this.buyerCountry = 'Nigeria',
//     this.vendorCountry = 'Nigeria',
//     this.total = 0.0,
//     required this.chats,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory MakeOffer.fromJson(Map<String, dynamic> json) {
//     double parseDouble(dynamic value) {
//       if (value == null) return 0.0;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? 0.0;
//       return 0.0;
//     }

//     return MakeOffer(
//       id: json['_id'] ?? '',
//       user: OfferUser.fromJson(json['userId'] ?? {}),
//       vendor: OfferVendor.fromJson(json['vendorId'] ?? {}),
//       materialId: json['materialId'] is String
//           ? json['materialId']
//           : (json['materialId']?['_id'] ?? ''),
//       reviewId: json['reviewId'] is String
//           ? json['reviewId']
//           : (json['reviewId']?['_id'] ?? ''),
//       status: json['status'] ?? 'pending',
//       buyerConsent: json['buyerConsent'] ?? false,
//       vendorConsent: json['vendorConsent'] ?? false,
//       mutualConsentAchieved: json['mutualConsentAchieved'] ?? false,
//       finalMaterialCost: parseDouble(json['finalMaterialCost']),
//       finalWorkmanshipCost: parseDouble(json['finalWorkmanshipCost']),
//       finalTotalCost: parseDouble(json['finalTotalCost']),
//       finalMaterialCostUSD: parseDouble(json['finalMaterialCostUSD']),
//       finalWorkmanshipCostUSD: parseDouble(json['finalWorkmanshipCostUSD']),
//       finalTotalCostUSD: parseDouble(json['finalTotalCostUSD']),
//       isInternationalVendor: json['isInternationalVendor'] ?? false,
//       exchangeRate: parseDouble(json['exchangeRate']),
//       buyerCountry: json['buyerCountry'] ?? 'Nigeria',
//       vendorCountry: json['vendorCountry'] ?? 'Nigeria',
//       total: parseDouble(json['total']),
//       chats: (json['chats'] as List<dynamic>?)
//               ?.map((e) => OfferChat.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//     );
//   }

//   // Helper methods
//   bool get canProceedToPayment => mutualConsentAchieved;

//   bool get isWaitingForBuyerConsent => vendorConsent && !buyerConsent;

//   bool get isWaitingForVendorConsent => buyerConsent && !vendorConsent;

//   OfferChat? get latestChat => chats.isNotEmpty ? chats.last : null;

//   String? get latestSenderType => latestChat?.senderType;

//   bool get buyerCanRespond => latestSenderType == 'vendor' || isWaitingForBuyerConsent;

//   bool get vendorCanRespond => latestSenderType == 'customer';
// }

// class OfferUser {
//   final String id;
//   final String fullName;
//   final String email;
//   final String? profileImage;
//   final String? role;

//   OfferUser({
//     required this.id,
//     required this.fullName,
//     required this.email,
//     this.profileImage,
//     this.role,
//   });

//   factory OfferUser.fromJson(Map<String, dynamic> json) {
//     return OfferUser(
//       id: json['_id'] ?? '',
//       fullName: json['fullName'] ?? '',
//       email: json['email'] ?? '',
//       profileImage: json['profileImage'],
//       role: json['role'],
//     );
//   }
// }

// class OfferVendor {
//   final String id;
//   final String businessName;
//   final OfferVendorUser? userId;

//   OfferVendor({
//     required this.id,
//     required this.businessName,
//     this.userId,
//   });

//   factory OfferVendor.fromJson(Map<String, dynamic> json) {
//     return OfferVendor(
//       id: json['_id'] ?? '',
//       businessName: json['businessName'] ?? '',
//       userId: json['userId'] != null
//           ? OfferVendorUser.fromJson(json['userId'])
//           : null,
//     );
//   }
// }

// class OfferVendorUser {
//   final String id;
//   final String fullName;
//   final String email;

//   OfferVendorUser({
//     required this.id,
//     required this.fullName,
//     required this.email,
//   });

//   factory OfferVendorUser.fromJson(Map<String, dynamic> json) {
//     return OfferVendorUser(
//       id: json['_id'] ?? '',
//       fullName: json['fullName'] ?? '',
//       email: json['email'] ?? '',
//     );
//   }
// }

// class OfferChat {
//   final String id;
//   final String senderType; // customer or vendor
//   final String action; // accepted, rejected, countered, pending, incoming
//   final double counterMaterialCost;
//   final double counterWorkmanshipCost;
//   final double counterTotalCost;
//   final String comment;
//   final DateTime timestamp;

//   OfferChat({
//     required this.id,
//     required this.senderType,
//     required this.action,
//     required this.counterMaterialCost,
//     required this.counterWorkmanshipCost,
//     required this.counterTotalCost,
//     required this.comment,
//     required this.timestamp,
//   });

//   factory OfferChat.fromJson(Map<String, dynamic> json) {
//     double parseDouble(dynamic value) {
//       if (value == null) return 0.0;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? 0.0;
//       return 0.0;
//     }

//     return OfferChat(
//       id: json['_id'] ?? '',
//       senderType: json['senderType'] ?? 'customer',
//       action: json['action'] ?? 'pending',
//       counterMaterialCost: parseDouble(json['counterMaterialCost']),
//       counterWorkmanshipCost: parseDouble(json['counterWorkmanshipCost']),
//       counterTotalCost: parseDouble(json['counterTotalCost']),
//       comment: json['comment'] ?? '',
//       timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
//     );
//   }

//   // UI helper methods
//   Color get actionBadgeColor {
//     switch (action) {
//       case 'accepted':
//         return const Color(0xFF10B981); // Green
//       case 'rejected':
//         return const Color(0xFFEF4444); // Red
//       case 'countered':
//         return const Color(0xFFF59E0B); // Orange
//       case 'incoming':
//         return const Color(0xFF3B82F6); // Blue
//       default:
//         return const Color(0xFFF59E0B); // Yellow
//     }
//   }

//   String get actionLabel {
//     switch (action) {
//       case 'accepted':
//         return 'Accepted';
//       case 'rejected':
//         return 'Rejected';
//       case 'countered':
//         return 'Counter Offer';
//       case 'incoming':
//         return 'Initial Offer';
//       default:
//         return 'Pending';
//     }
//   }

//   bool get showAmounts => action == 'countered' || action == 'incoming';
// }
