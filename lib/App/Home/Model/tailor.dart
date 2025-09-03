class Tailor {
  final String id;
  final User? user;
  final String? businessName;
  final String? businessEmail;
  final String? businessPhone;
  final String? address;
  final String? nepaBill;
  final String? city;
  final String? state;
  final String? yearOfExperience;
  final String? description;
  final int? totalRatings;
  final int? ratingSum;
  final List<Map<String, dynamic>> ratings;
  final String? createdAt;
  final String? updatedAt;

  Tailor({
    required this.id,
    this.user,
    this.businessName,
    this.businessEmail,
    this.businessPhone,
    this.address,
    this.nepaBill,
    this.city,
    this.state,
    this.yearOfExperience,
    this.description,
    this.totalRatings,
    this.ratingSum,
    this.ratings = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Tailor.fromJson(Map<String, dynamic> json) {
    return Tailor(
      id: json["_id"] ?? "",
      user: json["userId"] != null ? User.fromJson(json["userId"]) : null,
      businessName: json["businessName"],
      businessEmail: json["businessEmail"],
      businessPhone: json["businessPhone"],
      address: json["address"],
      nepaBill: json["nepaBill"],
      city: json["city"],
      state: json["state"],
      yearOfExperience: json["yearOfExperience"],
      description: json["description"],
      totalRatings: json["totalRatings"] ?? 0,
      ratingSum: json["ratingSum"] ?? 0,
      ratings: (json["ratings"] != null)
          ? List<Map<String, dynamic>>.from(json["ratings"])
          : [],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }
}

class User {
  final String id;
  final String? fullName;
  final String? email;
  final String? image;

  User({
    required this.id,
    this.fullName,
    this.email,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"] ?? "",
      fullName: json["fullName"],
      email: json["email"],
      image: json["image"], // sometimes not present
    );
  }
}
