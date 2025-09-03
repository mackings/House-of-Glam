class Category {
  final String id;
  final String name;
  final String description;
  final String image;
  final String createdAt;
  final String updatedAt;
  final int v;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["_id"] ?? "",
      name: json["name"] ?? "Unnamed",
      description: json["description"] ?? "",
      image: json["image"] ?? "https://via.placeholder.com/150",
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      v: json["__v"] ?? 0,
    );
  }
}
