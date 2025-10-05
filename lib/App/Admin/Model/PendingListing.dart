class PendingSellerListing {
  final String id;
  final String title;
  final String size;
  final String description;
  final String condition;
  final String status;
  final bool isApproved;
  final double price;
  final List<String> images;
  final DateTime createdAt;
  final SellerUser user;
  final ListingCategory category;

  PendingSellerListing({
    required this.id,
    required this.title,
    required this.size,
    required this.description,
    required this.condition,
    required this.status,
    required this.isApproved,
    required this.price,
    required this.images,
    required this.createdAt,
    required this.user,
    required this.category,
  });

  factory PendingSellerListing.fromJson(Map<String, dynamic> json) {
    return PendingSellerListing(
      id: json["_id"],
      title: json["title"],
      size: json["size"] ?? '',
      description: json["description"] ?? '',
      condition: json["condition"] ?? '',
      status: json["status"] ?? '',
      isApproved: json["isApproved"] ?? false,
      price: (json["price"] as num).toDouble(),
      images: List<String>.from(json["images"] ?? []),
      createdAt: DateTime.parse(json["createdAt"]),
      user: SellerUser.fromJson(json["userId"]),
      category: ListingCategory.fromJson(json["categoryId"]),
    );
  }
}

class SellerUser {
  final String id;
  final String fullName;
  final String address;
  final String? image;

  SellerUser({
    required this.id,
    required this.fullName,
    required this.address,
    this.image,
  });

  factory SellerUser.fromJson(Map<String, dynamic> json) {
    return SellerUser(
      id: json["_id"],
      fullName: json["fullName"] ?? '',
      address: json["address"] ?? '',
      image: json["image"],
    );
  }
}

class ListingCategory {
  final String id;
  final String name;

  ListingCategory({required this.id, required this.name});

  factory ListingCategory.fromJson(Map<String, dynamic> json) {
    return ListingCategory(id: json["_id"], name: json["name"] ?? '');
  }
}
