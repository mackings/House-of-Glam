class SellerListingResponse {
  final bool success;
  final String message;
  final List<SellerListing> data;

  SellerListingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SellerListingResponse.fromJson(Map<String, dynamic> json) {
    return SellerListingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>)
              .map((e) => SellerListing.fromJson(e))
              .toList(),
    );
  }
}

class SellerListing {
  final String id;
  final User user;
  final Category category;
  final String title;
  final String size;
  final String description;
  final String condition;
  final String status;
  final bool isApproved;
  final double price;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  SellerListing({
    required this.id,
    required this.user,
    required this.category,
    required this.title,
    required this.size,
    required this.description,
    required this.condition,
    required this.status,
    required this.isApproved,
    required this.price,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellerListing.fromJson(Map<String, dynamic> json) {
    return SellerListing(
      id: json['_id'],
      user: User.fromJson(json['userId']),
      category: Category.fromJson(json['categoryId']),
      title: json['title'] ?? '',
      size: json['size'] ?? '',
      description: json['description'] ?? '',
      condition: json['condition'] ?? '',
      status: json['status'] ?? '',
      isApproved: json['isApproved'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String address;
  final String? image;

  User({
    required this.id,
    required this.fullName,
    required this.address,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      image: json['image'], // might be null
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['_id'], name: json['name'] ?? '');
  }
}
