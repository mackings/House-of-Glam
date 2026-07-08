class SellerModerationListResponse {
  final List<SellerModerationListing> data;
  final PaginationMeta pagination;

  const SellerModerationListResponse({
    required this.data,
    required this.pagination,
  });

  factory SellerModerationListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List? ?? const [];
    return SellerModerationListResponse(
      data:
          rawData
              .map(
                (item) => SellerModerationListing.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
      pagination: PaginationMeta.fromJson(
        _asMap(json['pagination']) ?? const <String, dynamic>{},
      ),
    );
  }
}

class ListingModerationHistoryResponse {
  final List<ListingModerationFeedItem> data;
  final ListingModerationSummary summary;
  final PaginationMeta pagination;

  const ListingModerationHistoryResponse({
    required this.data,
    required this.summary,
    required this.pagination,
  });

  factory ListingModerationHistoryResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'] as List? ?? const [];
    return ListingModerationHistoryResponse(
      data:
          rawData
              .map(
                (item) => ListingModerationFeedItem.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
      summary: ListingModerationSummary.fromJson(
        _asMap(json['summary']) ?? const <String, dynamic>{},
      ),
      pagination: PaginationMeta.fromJson(
        _asMap(json['pagination']) ?? const <String, dynamic>{},
      ),
    );
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: _asInt(json['page']),
      limit: _asInt(json['limit']),
      total: _asInt(json['total']),
      totalPages: _asInt(json['totalPages'], fallback: 1),
    );
  }
}

class SellerModerationListing {
  final String id;
  final String title;
  final String size;
  final String description;
  final String condition;
  final String status;
  final String currency;
  final String approvalStatus;
  final bool isApproved;
  final double price;
  final List<String> images;
  final List<YardMeasurement> yards;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SellerUser user;
  final ListingCategory? category;
  final ModeratorInfo? approvedBy;
  final DateTime? approvedAt;
  final ModeratorInfo? rejectedBy;
  final DateTime? rejectedAt;
  final List<String> rejectionReasons;
  final List<ListingModerationEvent> moderationHistory;

  const SellerModerationListing({
    required this.id,
    required this.title,
    required this.size,
    required this.description,
    required this.condition,
    required this.status,
    required this.currency,
    required this.approvalStatus,
    required this.isApproved,
    required this.price,
    required this.images,
    required this.yards,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.category,
    required this.approvedBy,
    required this.approvedAt,
    required this.rejectedBy,
    required this.rejectedAt,
    required this.rejectionReasons,
    required this.moderationHistory,
  });

  factory SellerModerationListing.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['moderationHistory'] as List? ?? const [];
    return SellerModerationListing(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      condition: (json['condition'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      currency: (json['currency'] ?? 'NGN').toString(),
      approvalStatus: (json['approvalStatus'] ?? 'pending').toString(),
      isApproved: json['isApproved'] == true,
      price: _asDouble(json['price']),
      images: _asStringList(json['images']),
      yards: _asYardsList(json['yards']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      user: SellerUser.fromJson(_asMap(json['userId']) ?? const {}),
      category:
          _asMap(json['categoryId']) != null
              ? ListingCategory.fromJson(_asMap(json['categoryId'])!)
              : null,
      approvedBy: ModeratorInfo.fromDynamic(json['approvedBy']),
      approvedAt: _asDateTime(json['approvedAt']),
      rejectedBy: ModeratorInfo.fromDynamic(json['rejectedBy']),
      rejectedAt: _asDateTime(json['rejectedAt']),
      rejectionReasons: _asStringList(json['rejectionReasons']),
      moderationHistory:
          rawHistory
              .map(
                (item) => ListingModerationEvent.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
    );
  }

  bool get isPending => approvalStatus.toLowerCase() == 'pending';

  bool get isRejected => approvalStatus.toLowerCase() == 'rejected';

  bool get isApprovedStatus => approvalStatus.toLowerCase() == 'approved';
}

class SellerUser {
  final String id;
  final String fullName;
  final String address;
  final String? image;
  final String email;
  final String phoneNumber;
  final String subscriptionPlan;

  const SellerUser({
    required this.id,
    required this.fullName,
    required this.address,
    required this.image,
    required this.email,
    required this.phoneNumber,
    required this.subscriptionPlan,
  });

  factory SellerUser.fromJson(Map<String, dynamic> json) {
    return SellerUser(
      id: (json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      image: json['image']?.toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      subscriptionPlan: (json['subscriptionPlan'] ?? '').toString(),
    );
  }
}

class ListingCategory {
  final String id;
  final String name;

  const ListingCategory({required this.id, required this.name});

  factory ListingCategory.fromJson(Map<String, dynamic> json) {
    return ListingCategory(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class ModeratorInfo {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? image;

  const ModeratorInfo({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.image,
  });

  factory ModeratorInfo.fromJson(Map<String, dynamic> json) {
    return ModeratorInfo(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      image: json['image']?.toString(),
    );
  }

  static ModeratorInfo? fromDynamic(dynamic value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }
    return ModeratorInfo.fromJson(map);
  }
}

class ListingModerationEvent {
  final String id;
  final String action;
  final ModeratorInfo? moderator;
  final String moderatorName;
  final String moderatorRole;
  final String? reason;
  final DateTime? createdAt;

  const ListingModerationEvent({
    required this.id,
    required this.action,
    required this.moderator,
    required this.moderatorName,
    required this.moderatorRole,
    required this.reason,
    required this.createdAt,
  });

  factory ListingModerationEvent.fromJson(Map<String, dynamic> json) {
    return ListingModerationEvent(
      id: (json['_id'] ?? '').toString(),
      action: (json['action'] ?? '').toString(),
      moderator: ModeratorInfo.fromDynamic(json['moderatorId']),
      moderatorName: (json['moderatorName'] ?? '').toString(),
      moderatorRole: (json['moderatorRole'] ?? '').toString(),
      reason: json['reason']?.toString(),
      createdAt: _asDateTime(json['createdAt']),
    );
  }
}

class ListingModerationFeedItem {
  final String listingId;
  final String listingTitle;
  final String sellerId;
  final String categoryId;
  final String currentStatus;
  final String action;
  final String moderatorId;
  final String moderatorName;
  final String moderatorRole;
  final String? reason;
  final DateTime? moderatedAt;

  const ListingModerationFeedItem({
    required this.listingId,
    required this.listingTitle,
    required this.sellerId,
    required this.categoryId,
    required this.currentStatus,
    required this.action,
    required this.moderatorId,
    required this.moderatorName,
    required this.moderatorRole,
    required this.reason,
    required this.moderatedAt,
  });

  factory ListingModerationFeedItem.fromJson(Map<String, dynamic> json) {
    return ListingModerationFeedItem(
      listingId: (json['listingId'] ?? '').toString(),
      listingTitle: (json['listingTitle'] ?? '').toString(),
      sellerId: (json['sellerId'] ?? '').toString(),
      categoryId: (json['categoryId'] ?? '').toString(),
      currentStatus: (json['currentStatus'] ?? '').toString(),
      action: (json['action'] ?? '').toString(),
      moderatorId: (json['moderatorId'] ?? '').toString(),
      moderatorName: (json['moderatorName'] ?? '').toString(),
      moderatorRole: (json['moderatorRole'] ?? '').toString(),
      reason: json['reason']?.toString(),
      moderatedAt: _asDateTime(json['moderatedAt']),
    );
  }
}

class ListingModerationSummary {
  final int pending;
  final int approved;
  final int rejected;

  const ListingModerationSummary({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory ListingModerationSummary.fromJson(Map<String, dynamic> json) {
    return ListingModerationSummary(
      pending: _asInt(json['pending']),
      approved: _asInt(json['approved']),
      rejected: _asInt(json['rejected']),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  if (value is String && value.trim().isNotEmpty) {
    return [value.trim()];
  }

  return const [];
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

class YardMeasurement {
  final double length;
  final double width;

  const YardMeasurement({required this.length, required this.width});

  factory YardMeasurement.fromJson(Map<String, dynamic> json) {
    return YardMeasurement(
      length: _asDouble(json['length']),
      width: _asDouble(json['width']),
    );
  }

  String get label {
    String trim(double value) =>
        value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toString();
    return '${trim(length)} × ${trim(width)} yds';
  }
}

List<YardMeasurement> _asYardsList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => _asMap(item))
      .whereType<Map<String, dynamic>>()
      .map(YardMeasurement.fromJson)
      .where((yard) => yard.length > 0 || yard.width > 0)
      .toList();
}
