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

  static const Map<String, String> _assetImagesByName = {
    "agbada": "assets/Img/category_agbada.jpg",
    "aso oke": "assets/Img/category_aso_oke.jpg",
    "aso-oke": "assets/Img/category_aso_oke.jpg",
    "senator wear": "assets/Img/category_kaftan.jpg",
    "senator": "assets/Img/category_kaftan.jpg",
    "native gown": "assets/Img/category_african_dress.jpg",
    "native wear": "assets/Img/category_african_dress.jpg",
    "kaftan": "assets/Img/category_kaftan.jpg",
    "caftan": "assets/Img/category_kaftan.jpg",
    "boubou": "assets/Img/category_kaftan.jpg",
    "ankara": "assets/Img/category_ankara.jpg",
    "ankara styles": "assets/Img/category_ankara.jpg",
    "ankara fusion": "assets/Img/category_ankara_fusion.jpg",
    "wax print": "assets/Img/category_ankara.jpg",
    "african print": "assets/Img/category_ankara.jpg",
    "adire": "assets/Img/category_buba_sokoto.jpg",
    "buba": "assets/Img/category_buba_sokoto.jpg",
    "buba and sokoto": "assets/Img/category_buba_sokoto.jpg",
    "buba & sokoto": "assets/Img/category_buba_sokoto.jpg",
    "sokoto": "assets/Img/category_buba_sokoto.jpg",
    "iro and buba": "assets/Img/category_iro_buba.jpg",
    "iro & buba": "assets/Img/category_iro_buba.jpg",
    "gele": "assets/Img/category_gele.jpg",
    "george wrapper": "assets/Img/category_iro_buba.jpg",
    "wrapper": "assets/Img/category_iro_buba.jpg",
    "dashiki": "assets/Img/category_dashiki.jpg",
    "blouse": "assets/Img/category_gele.jpg",
    "blouse and gele": "assets/Img/category_gele.jpg",
    "lace": "assets/Img/category_gele.jpg",
    "corporate suit": "assets/Img/category_ankara_fusion.jpg",
    "suit": "assets/Img/category_ankara_fusion.jpg",
    "suits": "assets/Img/category_ankara_fusion.jpg",
    "corporate": "assets/Img/category_ankara_fusion.jpg",
    "casual wear": "assets/Img/category_aso_ebi.jpg",
    "evening gown": "assets/Img/category_african_dress.jpg",
    "wedding dress": "assets/Img/category_aso_ebi.jpg",
    "party dress": "assets/Img/category_african_dress.jpg",
    "jumpsuit": "assets/Img/category_ankara_fusion.jpg",
    "skirt and blouse": "assets/Img/category_ankara.jpg",
    "trouser and shirt": "assets/Img/category_dashiki.jpg",
    "smart casual": "assets/Img/category_ankara_fusion.jpg",
    "children's traditional": "assets/Img/category_children_traditional.jpg",
    "childrens traditional": "assets/Img/category_children_traditional.jpg",
    "children traditional": "assets/Img/category_children_traditional.jpg",
    "children's casual": "assets/Img/category_children_casual.jpg",
    "childrens casual": "assets/Img/category_children_casual.jpg",
    "children casual": "assets/Img/category_children_casual.jpg",
    "muslim wear": "assets/Img/category_kaftan.jpg",
    "choir robe": "assets/Img/category_choir_robe.jpg",
    "traditional accessories": "assets/Img/category_accessories.jpg",
    "accessories": "assets/Img/category_accessories.jpg",
  };

  static String? assetImageForName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    final exactMatch = _assetImagesByName[normalized];
    if (exactMatch != null) {
      return exactMatch;
    }

    for (final entry in _assetImagesByName.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  static bool isAssetImage(String image) {
    return image.trim().startsWith("assets/");
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final name = json["name"] ?? "Unnamed";
    final apiImage = json["image"] ?? "";
    return Category(
      id: json["_id"] ?? "",
      name: name,
      description: json["description"] ?? "",
      image:
          assetImageForName(name) ??
          (apiImage.isNotEmpty ? apiImage : "https://via.placeholder.com/150"),
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      v: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "description": description,
      "image": image,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
    };
  }
}
