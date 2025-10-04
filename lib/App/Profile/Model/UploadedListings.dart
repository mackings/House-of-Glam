class UserListing {
  final String id;
  final String title;
  final String size;
  final String description;
  final String condition;
  final String status;
  final double price;
  final List<String> images;
  final DateTime createdAt;

  UserListing({
    required this.id,
    required this.title,
    required this.size,
    required this.description,
    required this.condition,
    required this.status,
    required this.price,
    required this.images,
    required this.createdAt,
  });

  factory UserListing.fromJson(Map<String, dynamic> json) {
    return UserListing(
      id: json["_id"],
      title: json["title"],
      size: json["size"],
      description: json["description"],
      condition: json["condition"],
      status: json["status"],
      price: (json["price"] as num).toDouble(),
      images: List<String>.from(json["images"] ?? []),
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
