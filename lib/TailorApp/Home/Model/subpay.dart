class SubscriptionPaymentResponse {
  final bool success;
  final String message;
  final String provider;
  final String authorizationUrl;
  final String checkoutUrl;
  final String sessionId;
  final SubscriptionPaymentData data;
  final SubscriptionPaymentBreakdown breakdown;

  SubscriptionPaymentResponse({
    required this.success,
    required this.message,
    required this.provider,
    required this.authorizationUrl,
    required this.checkoutUrl,
    required this.sessionId,
    required this.data,
    required this.breakdown,
  });

  factory SubscriptionPaymentResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    final breakdownJson = json['breakdown'];
    return SubscriptionPaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      provider: json['provider'] ?? '',
      authorizationUrl: json['authorizationUrl'] ?? '',
      checkoutUrl: json['checkoutUrl'] ?? '',
      sessionId: json['sessionId'] ?? '',
      data:
          dataJson is Map<String, dynamic>
              ? SubscriptionPaymentData.fromJson(dataJson)
              : SubscriptionPaymentData.empty(),
      breakdown:
          breakdownJson is Map<String, dynamic>
              ? SubscriptionPaymentBreakdown.fromJson(breakdownJson)
              : SubscriptionPaymentBreakdown.empty(),
    );
  }
}

class SubscriptionPaymentBreakdown {
  final String plan;
  final String billTerm;
  final List<String> benefits;
  final double amountNGN;
  final double amountUSD;
  final double exchangeRate;
  final String currency;

  const SubscriptionPaymentBreakdown({
    required this.plan,
    required this.billTerm,
    required this.benefits,
    required this.amountNGN,
    required this.amountUSD,
    required this.exchangeRate,
    required this.currency,
  });

  factory SubscriptionPaymentBreakdown.empty() {
    return const SubscriptionPaymentBreakdown(
      plan: '',
      billTerm: '',
      benefits: [],
      amountNGN: 0,
      amountUSD: 0,
      exchangeRate: 0,
      currency: '',
    );
  }

  factory SubscriptionPaymentBreakdown.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return SubscriptionPaymentBreakdown(
      plan: json['plan']?.toString() ?? '',
      billTerm: json['billTerm']?.toString() ?? '',
      benefits:
          json['benefits'] is List
              ? (json['benefits'] as List)
                  .map((benefit) => benefit.toString())
                  .toList()
              : const [],
      amountNGN: number(json['amountNGN']),
      amountUSD: number(json['amountUSD']),
      exchangeRate: number(json['exchangeRate']),
      currency: json['currency']?.toString() ?? '',
    );
  }
}

class SubscriptionPaymentData {
  final String id;
  final String userId;
  final String plan;
  final String billTerm;
  final String paymentStatus;
  final int totalAmount;
  final double amountPaidUSD;
  final double exchangeRate;
  final String paymentReference;
  final String paymentMethod;
  final String planId;
  final List<String> planBenefits;
  final int amountPaid;
  final String subscriptionStartDate;
  final String subscriptionEndDate;

  SubscriptionPaymentData({
    required this.id,
    required this.userId,
    required this.plan,
    required this.billTerm,
    required this.paymentStatus,
    required this.totalAmount,
    required this.amountPaidUSD,
    required this.exchangeRate,
    required this.paymentReference,
    required this.paymentMethod,
    required this.planId,
    required this.planBenefits,
    required this.amountPaid,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
  });

  factory SubscriptionPaymentData.empty() {
    return SubscriptionPaymentData(
      id: '',
      userId: '',
      plan: '',
      billTerm: '',
      paymentStatus: '',
      totalAmount: 0,
      amountPaidUSD: 0,
      exchangeRate: 0,
      paymentReference: '',
      paymentMethod: '',
      planId: '',
      planBenefits: const [],
      amountPaid: 0,
      subscriptionStartDate: '',
      subscriptionEndDate: '',
    );
  }

  factory SubscriptionPaymentData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      plan: json['plan'] ?? '',
      billTerm: json['billTerm'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      amountPaidUSD: (json['amountPaidUSD'] ?? 0).toDouble(),
      exchangeRate: (json['exchangeRate'] ?? 0).toDouble(),
      paymentReference: json['paymentReference'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      planId: json['planId'] ?? '',
      planBenefits:
          json['planBenefits'] is List
              ? (json['planBenefits'] as List)
                  .map((benefit) => benefit.toString())
                  .toList()
              : const [],
      amountPaid:
          json['amountPaid'] is num
              ? (json['amountPaid'] as num).toInt()
              : int.tryParse(json['amountPaid']?.toString() ?? '') ?? 0,
      subscriptionStartDate: json['subscriptionStartDate'] ?? '',
      subscriptionEndDate: json['subscriptionEndDate'] ?? '',
    );
  }
}
