class VendorDetailsResponse {
  final bool success;
  final String message;
  final Vendor vendor;
  final UserProfile userProfile;

  VendorDetailsResponse({
    required this.success,
    required this.message,
    required this.vendor,
    required this.userProfile,
  });

  factory VendorDetailsResponse.fromJson(Map<String, dynamic> json) {
    return VendorDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      vendor: Vendor.fromJson(json['data']['vendor']),
      userProfile: UserProfile.fromJson(json['data']['userProfile']),
    );
  }
}

class Vendor {
  final String id;
  final String userId;
  final String businessName;
  final String businessEmail;
  final String businessPhone;
  final String address;
  final String nepaBill;
  final String city;
  final String state;
  final String yearOfExperience;
  final String description;
  final int rate;
  final String createdAt;
  final String updatedAt;
  final int ratingSum;
  final int totalRatings;
  final List<String> ratings;

  Vendor({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessEmail,
    required this.businessPhone,
    required this.address,
    required this.nepaBill,
    required this.city,
    required this.state,
    required this.yearOfExperience,
    required this.description,
    required this.rate,
    required this.createdAt,
    required this.updatedAt,
    required this.ratingSum,
    required this.totalRatings,
    required this.ratings,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      businessName: json['businessName'] ?? '',
      businessEmail: json['businessEmail'] ?? '',
      businessPhone: json['businessPhone'] ?? '',
      address: json['address'] ?? '',
      nepaBill: json['nepaBill'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      yearOfExperience: json['yearOfExperience'] ?? '',
      description: json['description'] ?? '',
      rate: json['rate'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      ratingSum: json['ratingSum'] ?? 0,
      totalRatings: json['totalRatings'] ?? 0,
      ratings: (json['ratings'] as List<dynamic>?)
              ?.map((r) => r['_id'] as String)
              .toList() ??
          [],
    );
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String image;
  final String address;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.image,
    required this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      image: json['image'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
