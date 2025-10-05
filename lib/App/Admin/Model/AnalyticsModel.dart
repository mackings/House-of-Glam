class TotalUsersResponse {
  final bool success;
  final String message;
  final int totalUsers;

  TotalUsersResponse({
    required this.success,
    required this.message,
    required this.totalUsers,
  });

  factory TotalUsersResponse.fromJson(Map<String, dynamic> json) {
    return TotalUsersResponse(
      success: json['success'],
      message: json['message'],
      totalUsers: json['data'],
    );
  }
}

class FreePaidListingsResponse {
  final bool success;
  final String message;
  final int freeListings;
  final int paidListings;

  FreePaidListingsResponse({
    required this.success,
    required this.message,
    required this.freeListings,
    required this.paidListings,
  });

  factory FreePaidListingsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return FreePaidListingsResponse(
      success: json['success'],
      message: json['message'],
      freeListings: data['freeListings'],
      paidListings: data['paidListings'],
    );
  }
}

class TotalEarningsResponse {
  final bool success;
  final String message;
  final double totalEarnings;

  TotalEarningsResponse({
    required this.success,
    required this.message,
    required this.totalEarnings,
  });

  factory TotalEarningsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TotalEarningsResponse(
      success: json['success'],
      message: json['message'],
      totalEarnings: (data['totalEarnings'] as num).toDouble(),
    );
  }
}

class TotalTransactionsResponse {
  final bool success;
  final String message;
  final int totalTransactions;

  TotalTransactionsResponse({
    required this.success,
    required this.message,
    required this.totalTransactions,
  });

  factory TotalTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TotalTransactionsResponse(
      success: json['success'],
      message: json['message'],
      totalTransactions: data['totalTransactions'],
    );
  }
}

class TotalListingsResponse {
  final bool success;
  final String message;
  final int totalListings;

  TotalListingsResponse({
    required this.success,
    required this.message,
    required this.totalListings,
  });

  factory TotalListingsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TotalListingsResponse(
      success: json['success'],
      message: json['message'],
      totalListings: data['totalListings'],
    );
  }
}
