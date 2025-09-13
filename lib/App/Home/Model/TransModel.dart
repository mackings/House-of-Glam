class TransactionResponse {
  final String? id;
  final String? userId;
  final String? vendorId;
  final String? materialId;
  final List<CartItem> cartItems;
  final int? totalAmount;
  final String? paymentMethod;
  final String? paymentReference;
  final String? deliveryAddress;
  final String? paymentStatus;
  final String? paymentCurrency;
  final String? orderStatus;
  final int? amountPaid;
  final String? createdAt;
  final String? updatedAt;

  TransactionResponse({
    this.id,
    this.userId,
    this.vendorId,
    this.materialId,
    required this.cartItems,
    this.totalAmount,
    this.paymentMethod,
    this.paymentReference,
    this.deliveryAddress,
    this.paymentStatus,
    this.paymentCurrency,
    this.orderStatus,
    this.amountPaid,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json["_id"],
      userId: json["userId"],
      vendorId: json["vendorId"],
      materialId: json["materialId"],
      cartItems: (json["cartItems"] as List? ?? [])
          .map((e) => CartItem.fromJson(e))
          .toList(),
      totalAmount: json["totalAmount"],
      paymentMethod: json["paymentMethod"],
      paymentReference: json["paymentReference"],
      deliveryAddress: json["deliveryAddress"],
      paymentStatus: json["paymentStatus"],
      paymentCurrency: json["paymentCurrency"],
      orderStatus: json["orderStatus"],
      amountPaid: json["amountPaid"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }
}

class CartItem {
  final String attireType;
  final String clothMaterial;
  final String color;
  final String brand;
  final List<Measurement> measurement;
  final List<String> sampleImage;

  CartItem({
    required this.attireType,
    required this.clothMaterial,
    required this.color,
    required this.brand,
    required this.measurement,
    required this.sampleImage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      attireType: json["attireType"],
      clothMaterial: json["clothMaterial"],
      color: json["color"],
      brand: json["brand"],
      measurement: (json["measurement"] as List? ?? [])
          .map((e) => Measurement.fromJson(e))
          .toList(),
      sampleImage: List<String>.from(json["sampleImage"] ?? []),
    );
  }
}

class Measurement {
  final int? neck;
  final int? shoulder;
  final int? chest;
  final int? waist;
  final int? hip;
  final int? length;
  final int? shoulderLength;
  final int? armLength;
  final int? aroundArm;
  final int? wrist;
  final int? collarFront;
  final int? collarBack;
  final int? sleeveLength;
  final String armType;

  Measurement({
    this.neck,
    this.shoulder,
    this.chest,
    this.waist,
    this.hip,
    this.length,
    this.shoulderLength,
    this.armLength,
    this.aroundArm,
    this.wrist,
    this.collarFront,
    this.collarBack,
    this.sleeveLength,
    required this.armType,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      neck: json["neck"],
      shoulder: json["shoulder"],
      chest: json["chest"],
      waist: json["waist"],
      hip: json["hip"],
      length: json["length"],
      shoulderLength: json["shoulder"],
      armLength: json["armLength"] ?? json["armlength"],
      aroundArm: json["aroundArm"] ?? json["aroundarm"],
      wrist: json["wrist"],
      collarFront: json["collarFront"] ?? json["collarfront"],
      collarBack: json["collarBack"] ?? json["collarback"],
      sleeveLength: json["sleeveLength"] ?? json["sleevelength"],
      armType: json["armType"] ?? "",
    );
  }
}

class TransactionListResponse {
  final String message;
  final List<TransactionResponse> transactions;

  TransactionListResponse({
    required this.message,
    required this.transactions,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      message: json["message"] ?? "",
      transactions: (json["data"] as List? ?? [])
          .map((e) => TransactionResponse.fromJson(e))
          .toList(),
    );
  }
}



