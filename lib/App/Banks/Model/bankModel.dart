// models/bank_model.dart
class Bank {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String bankCode;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // ✅ NEW: Stripe-specific fields
  final String? stripeAccountId;
  final String? stripeAccountType; // 'express', 'standard'
  final bool? stripeOnboardingComplete;
  final String? countryCode; // e.g., 'US', 'GB', 'NG'
  final String? currency; // e.g., 'USD', 'GBP', 'NGN'
  final String? provider; // 'paystack', 'stripe', 'flutterwave'
  
  // ✅ NEW: International bank details
  final String? routingNumber; // US
  final String? sortCode; // UK
  final String? iban; // EU
  final String? swiftCode; // International

  Bank({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.bankCode,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.stripeAccountId,
    this.stripeAccountType,
    this.stripeOnboardingComplete,
    this.countryCode,
    this.currency,
    this.provider,
    this.routingNumber,
    this.sortCode,
    this.iban,
    this.swiftCode,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['_id'] ?? json['id'] ?? '',
      bankName: json['bankName'] ?? json['bank_name'] ?? '',
      accountNumber: json['accountNumber'] ?? json['last4'] ?? '',
      accountName: json['accountName'] ?? '',
      bankCode: json['bankCode'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),

      // ✅ Parse Stripe fields
      stripeAccountId: json['stripeAccountId'],
      stripeAccountType: json['stripeAccountType'],
      stripeOnboardingComplete: json['stripeOnboardingComplete'],
      countryCode: json['countryCode'] ?? json['country'],
      currency: json['currency'],
      provider: json['provider'],
      routingNumber: json['routingNumber'],
      sortCode: json['sortCode'],
      iban: json['iban'],
      swiftCode: json['swiftCode'],
    );
  }

  /// Factory for Stripe bank account from API response
  factory Bank.fromStripeJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] ?? '',
      bankName: (json['bank_name'] ?? 'STRIPE TEST BANK').toString().toUpperCase(),
      accountNumber: '****${json['last4'] ?? ''}',
      accountName: json['account_holder_name'] ?? 'Stripe Account',
      bankCode: '',
      userId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stripeAccountId: json['id'],
      countryCode: json['country']?.toString().toUpperCase(),
      currency: json['currency']?.toString().toUpperCase(),
      provider: 'stripe',
      stripeOnboardingComplete: json['status'] == 'verified' || json['status'] == 'new',
    );
  }

  /// Factory for local bank account from API response
  factory Bank.fromLocalJson(Map<String, dynamic> json) {
    return Bank(
      id: json['_id'] ?? '',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountName: json['accountName'] ?? '',
      bankCode: json['bankCode'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      provider: 'paystack',
      countryCode: 'NG',
      currency: 'NGN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bankCode': bankCode,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      
      // ✅ NEW: Include Stripe fields if present
      if (stripeAccountId != null) 'stripeAccountId': stripeAccountId,
      if (stripeAccountType != null) 'stripeAccountType': stripeAccountType,
      if (stripeOnboardingComplete != null) 'stripeOnboardingComplete': stripeOnboardingComplete,
      if (countryCode != null) 'countryCode': countryCode,
      if (currency != null) 'currency': currency,
      if (provider != null) 'provider': provider,
      if (routingNumber != null) 'routingNumber': routingNumber,
      if (sortCode != null) 'sortCode': sortCode,
      if (iban != null) 'iban': iban,
      if (swiftCode != null) 'swiftCode': swiftCode,
    };
  }
  
  // ✅ NEW: Helper getters
  bool get isStripeAccount => provider?.toLowerCase() == 'stripe';
  bool get isLocalBank => provider?.toLowerCase() == 'paystack' || provider?.toLowerCase() == 'flutterwave';
  bool get isStripeOnboardingComplete => stripeOnboardingComplete ?? false;
  
  String get displayProvider {
    if (provider == null) return 'Local Bank';
    switch (provider!.toLowerCase()) {
      case 'stripe':
        return 'Stripe';
      case 'paystack':
        return 'Paystack';
      case 'flutterwave':
        return 'Flutterwave';
      default:
        return 'Local Bank';
    }
  }
  
  String get displayCurrency => currency ?? 'NGN';
  String get displayCountry => countryCode ?? 'NG';
}