class UserProfile {
  final String? id;
  final String? fullName;
  final String? email;
  final bool? isVerified;
  final bool? isBlocked;
  //final int? wallet;
  final String? billImage;
  final String? address;
  final String? subscriptionPlan;
  final String? phoneNumber;
  final String? role;
  final bool? isVendorEnabled;
  final String? country;
  final String? createdAt;

  UserProfile({
    this.id,
    this.fullName,
    this.email,
    this.isVerified,
    this.isBlocked,
    //this.wallet,
    this.billImage,
    this.address,
    this.subscriptionPlan,
    this.phoneNumber,
    this.role,
    this.isVendorEnabled,
    this.country,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["_id"],
      fullName: json["fullName"],
      email: json["email"],
      isVerified: json["isVerified"],
      isBlocked: json["isBlocked"],
      // wallet: json["wallet"],
      billImage: json["billImage"],
      address: json["address"],
      subscriptionPlan: json["subscriptionPlan"],
      phoneNumber: json["phoneNumber"],
      role: json["role"],
      isVendorEnabled: json["isVendorEnabled"],
      country: json["country"],
      createdAt: json["createdAt"],
    );
  }
}
