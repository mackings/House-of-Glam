class SubscriptionPaymentResponse {
  final bool success;
  final String message;
  final String provider;
  final String authorizationUrl;
  final String checkoutUrl;
  final String sessionId;
  final SubscriptionPaymentData data;

  SubscriptionPaymentResponse({
    required this.success,
    required this.message,
    required this.provider,
    required this.authorizationUrl,
    required this.checkoutUrl,
    required this.sessionId,
    required this.data,
  });

  factory SubscriptionPaymentResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
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
      subscriptionStartDate: json['subscriptionStartDate'] ?? '',
      subscriptionEndDate: json['subscriptionEndDate'] ?? '',
    );
  }
}
