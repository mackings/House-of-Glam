class AdminAnalyticsResponse {
  final bool success;
  final String message;
  final AdminAnalyticsData data;

  const AdminAnalyticsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdminAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: AdminAnalyticsData.fromJson(_map(json['data'])),
    );
  }
}

class AdminAnalyticsData {
  final UserAnalytics users;
  final ListingAnalytics listings;
  final EarningsAnalytics earnings;
  final TransactionAnalytics transactions;
  final DateTime? generatedAt;

  const AdminAnalyticsData({
    required this.users,
    required this.listings,
    required this.earnings,
    required this.transactions,
    this.generatedAt,
  });

  factory AdminAnalyticsData.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsData(
      users: UserAnalytics.fromJson(_map(json['users'])),
      listings: ListingAnalytics.fromJson(_map(json['listings'])),
      earnings: EarningsAnalytics.fromJson(_map(json['earnings'])),
      transactions: TransactionAnalytics.fromJson(_map(json['transactions'])),
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? ''),
    );
  }
}

class UserAnalytics {
  final int totalUsers;
  final Map<String, int> byRole;
  final Map<String, int> bySubscriptionPlan;
  final Map<String, int> verification;
  final Map<String, int> accountStatus;
  final int registeredLast30Days;

  const UserAnalytics({
    required this.totalUsers,
    required this.byRole,
    required this.bySubscriptionPlan,
    required this.verification,
    required this.accountStatus,
    required this.registeredLast30Days,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      totalUsers: _integer(json['totalUsers']),
      byRole: _integerMap(json['byRole']),
      bySubscriptionPlan: _integerMap(json['bySubscriptionPlan']),
      verification: _integerMap(json['verification']),
      accountStatus: _integerMap(json['accountStatus']),
      registeredLast30Days: _integer(json['registeredLast30Days']),
    );
  }
}

class ListingAnalytics {
  final int totalListings;
  final int freeListings;
  final int paidListings;
  final int unpricedListings;
  final Map<String, int> byApprovalStatus;
  final Map<String, int> byAvailability;
  final Map<String, int> featured;
  final double totalListedValue;
  final double averageListedValue;
  final String currencyNote;

  const ListingAnalytics({
    required this.totalListings,
    required this.freeListings,
    required this.paidListings,
    required this.unpricedListings,
    required this.byApprovalStatus,
    required this.byAvailability,
    required this.featured,
    required this.totalListedValue,
    required this.averageListedValue,
    required this.currencyNote,
  });

  factory ListingAnalytics.fromJson(Map<String, dynamic> json) {
    final listedValue = _map(json['listedValue']);
    return ListingAnalytics(
      totalListings: _integer(json['totalListings']),
      freeListings: _integer(json['freeListings']),
      paidListings: _integer(json['paidListings']),
      unpricedListings: _integer(json['unpricedListings']),
      byApprovalStatus: _integerMap(json['byApprovalStatus']),
      byAvailability: _integerMap(json['byAvailability']),
      featured: _integerMap(json['featured']),
      totalListedValue: _decimal(listedValue['total']),
      averageListedValue: _decimal(listedValue['average']),
      currencyNote: listedValue['currencyNote']?.toString() ?? '',
    );
  }
}

class EarningsAnalytics {
  final double totalEarnings;
  final String currency;
  final String basis;
  final double recordedCommission;
  final double recordedTax;
  final double otherWalletCredits;
  final String note;

  const EarningsAnalytics({
    required this.totalEarnings,
    required this.currency,
    required this.basis,
    required this.recordedCommission,
    required this.recordedTax,
    required this.otherWalletCredits,
    required this.note,
  });

  factory EarningsAnalytics.fromJson(Map<String, dynamic> json) {
    final derivation = _map(json['derivation']);
    return EarningsAnalytics(
      totalEarnings: _decimal(json['totalEarnings']),
      currency: json['currency']?.toString() ?? 'NGN',
      basis: json['basis']?.toString() ?? '',
      recordedCommission: _decimal(derivation['recordedCommission']),
      recordedTax: _decimal(derivation['recordedTax']),
      otherWalletCredits: _decimal(derivation['otherWalletCredits']),
      note: json['note']?.toString() ?? '',
    );
  }
}

class TransactionAnalytics {
  final int totalTransactions;
  final int successfulTransactions;
  final Map<String, int> byPaymentStatus;
  final Map<String, int> byOrderStatus;
  final Map<String, int> byTransactionStatus;
  final Map<String, int> byTransactionType;
  final Map<String, int> byPaymentMethod;
  final Map<String, int> byCategory;
  final Map<String, TransactionCurrencyAnalytics> amountsByCurrency;

  const TransactionAnalytics({
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.byPaymentStatus,
    required this.byOrderStatus,
    required this.byTransactionStatus,
    required this.byTransactionType,
    required this.byPaymentMethod,
    required this.byCategory,
    required this.amountsByCurrency,
  });

  factory TransactionAnalytics.fromJson(Map<String, dynamic> json) {
    final currencies = <String, TransactionCurrencyAnalytics>{};
    _map(json['amountsByCurrency']).forEach((key, value) {
      currencies[key] = TransactionCurrencyAnalytics.fromJson(_map(value));
    });

    return TransactionAnalytics(
      totalTransactions: _integer(json['totalTransactions']),
      successfulTransactions: _integer(json['successfulTransactions']),
      byPaymentStatus: _integerMap(json['byPaymentStatus']),
      byOrderStatus: _integerMap(json['byOrderStatus']),
      byTransactionStatus: _integerMap(json['byTransactionStatus']),
      byTransactionType: _integerMap(json['byTransactionType']),
      byPaymentMethod: _integerMap(json['byPaymentMethod']),
      byCategory: _integerMap(json['byCategory']),
      amountsByCurrency: currencies,
    );
  }
}

class TransactionCurrencyAnalytics {
  final int transactionCount;
  final double totalAmount;

  const TransactionCurrencyAnalytics({
    required this.transactionCount,
    required this.totalAmount,
  });

  factory TransactionCurrencyAnalytics.fromJson(Map<String, dynamic> json) {
    return TransactionCurrencyAnalytics(
      transactionCount: _integer(json['transactionCount']),
      totalAmount: _decimal(json['totalAmount']),
    );
  }
}

class AnalyticsPagination {
  final int page;
  final int limit;
  final int totalRecords;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const AnalyticsPagination({
    required this.page,
    required this.limit,
    required this.totalRecords,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory AnalyticsPagination.fromJson(Map<String, dynamic> json) {
    return AnalyticsPagination(
      page: _integer(json['page']),
      limit: _integer(json['limit']),
      totalRecords: _integer(json['totalRecords']),
      totalPages: _integer(json['totalPages']),
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
    );
  }
}

class AnalyticsUsersPage {
  final UserAnalytics summary;
  final List<AnalyticsUserRecord> records;
  final AnalyticsPagination pagination;

  const AnalyticsUsersPage({
    required this.summary,
    required this.records,
    required this.pagination,
  });

  factory AnalyticsUsersPage.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']);
    return AnalyticsUsersPage(
      summary: UserAnalytics.fromJson(_map(data['summary'])),
      records:
          _list(
            data['records'],
          ).map((item) => AnalyticsUserRecord.fromJson(_map(item))).toList(),
      pagination: AnalyticsPagination.fromJson(_map(data['pagination'])),
    );
  }
}

class AnalyticsUserRecord {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String phoneNumber;
  final String image;
  final String role;
  final String country;
  final double wallet;
  final String subscriptionPlan;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final String billTerm;
  final bool isVerified;
  final bool isBlocked;
  final bool isVendorEnabled;
  final DateTime? createdAt;

  const AnalyticsUserRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.image,
    required this.role,
    required this.country,
    required this.wallet,
    required this.subscriptionPlan,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    required this.billTerm,
    required this.isVerified,
    required this.isBlocked,
    required this.isVendorEnabled,
    required this.createdAt,
  });

  factory AnalyticsUserRecord.fromJson(Map<String, dynamic> json) {
    return AnalyticsUserRecord(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      wallet: _decimal(json['wallet']),
      subscriptionPlan: json['subscriptionPlan']?.toString() ?? '',
      subscriptionStartDate: _date(json['subscriptionStartDate']),
      subscriptionEndDate: _date(json['subscriptionEndDate']),
      billTerm: json['billTerm']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      isBlocked: json['isBlocked'] == true,
      isVendorEnabled: json['isVendorEnabled'] == true,
      createdAt: _date(json['createdAt']),
    );
  }
}

class AnalyticsListingsPage {
  final ListingAnalytics summary;
  final List<Map<String, dynamic>> records;
  final AnalyticsPagination pagination;

  const AnalyticsListingsPage({
    required this.summary,
    required this.records,
    required this.pagination,
  });

  factory AnalyticsListingsPage.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']);
    return AnalyticsListingsPage(
      summary: ListingAnalytics.fromJson(_map(data['summary'])),
      records: _list(data['records']).map(_map).toList(),
      pagination: AnalyticsPagination.fromJson(_map(data['pagination'])),
    );
  }
}

class AnalyticsTransactionsPage {
  final TransactionAnalytics summary;
  final List<AnalyticsTransactionRecord> records;
  final AnalyticsPagination pagination;

  const AnalyticsTransactionsPage({
    required this.summary,
    required this.records,
    required this.pagination,
  });

  factory AnalyticsTransactionsPage.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']);
    return AnalyticsTransactionsPage(
      summary: TransactionAnalytics.fromJson(_map(data['summary'])),
      records:
          _list(data['records'])
              .map((item) => AnalyticsTransactionRecord.fromJson(_map(item)))
              .toList(),
      pagination: AnalyticsPagination.fromJson(_map(data['pagination'])),
    );
  }
}

class AnalyticsTransactionRecord {
  final String id;
  final String userName;
  final String userEmail;
  final String vendorName;
  final String materialTitle;
  final List<String> listingTitles;
  final double totalAmount;
  final double amountPaid;
  final double analyticsAmount;
  final String paymentMethod;
  final String paymentReference;
  final String paymentStatus;
  final String currency;
  final String orderStatus;
  final String transactionStatus;
  final String transactionType;
  final DateTime? createdAt;

  const AnalyticsTransactionRecord({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.vendorName,
    required this.materialTitle,
    required this.listingTitles,
    required this.totalAmount,
    required this.amountPaid,
    required this.analyticsAmount,
    required this.paymentMethod,
    required this.paymentReference,
    required this.paymentStatus,
    required this.currency,
    required this.orderStatus,
    required this.transactionStatus,
    required this.transactionType,
    required this.createdAt,
  });

  factory AnalyticsTransactionRecord.fromJson(Map<String, dynamic> json) {
    final user = _map(json['userId']);
    final vendor = _map(json['vendorId']);
    final material = _map(json['materialId']);
    return AnalyticsTransactionRecord(
      id: json['_id']?.toString() ?? '',
      userName: user['fullName']?.toString() ?? '',
      userEmail: user['email']?.toString() ?? '',
      vendorName: vendor['businessName']?.toString() ?? '',
      materialTitle:
          material['attireType']?.toString() ??
          material['title']?.toString() ??
          '',
      listingTitles:
          _list(json['listingId'])
              .map((item) => _map(item)['title']?.toString() ?? '')
              .where((title) => title.isNotEmpty)
              .toList(),
      totalAmount: _decimal(json['totalAmount']),
      amountPaid: _decimal(json['amountPaid']),
      analyticsAmount: _decimal(json['analyticsAmount']),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentReference: json['paymentReference']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      currency:
          json['paymentCurrency']?.toString() ??
          json['currency']?.toString() ??
          'NGN',
      orderStatus: json['orderStatus']?.toString() ?? '',
      transactionStatus:
          json['transactionStatus']?.toString() ??
          json['status']?.toString() ??
          '',
      transactionType: json['transactionType']?.toString() ?? '',
      createdAt: _date(json['createdAt']),
    );
  }
}

class AnalyticsEarningsPage {
  final EarningsAnalytics earnings;
  final TransactionAnalytics transactionSummary;
  final List<AnalyticsTransactionRecord> transactionActivity;
  final AnalyticsPagination pagination;
  final String note;

  const AnalyticsEarningsPage({
    required this.earnings,
    required this.transactionSummary,
    required this.transactionActivity,
    required this.pagination,
    required this.note,
  });

  factory AnalyticsEarningsPage.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']);
    return AnalyticsEarningsPage(
      earnings: EarningsAnalytics.fromJson(_map(data['earnings'])),
      transactionSummary: TransactionAnalytics.fromJson(
        _map(data['transactionSummary']),
      ),
      transactionActivity:
          _list(data['transactionActivity'])
              .map((item) => AnalyticsTransactionRecord.fromJson(_map(item)))
              .toList(),
      pagination: AnalyticsPagination.fromJson(_map(data['pagination'])),
      note: data['transactionActivityNote']?.toString() ?? '',
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : {};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

DateTime? _date(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '');
}

Map<String, int> _integerMap(dynamic value) {
  final result = <String, int>{};
  _map(value).forEach((key, item) {
    result[key] = _integer(item);
  });
  return result;
}

int _integer(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _decimal(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

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
