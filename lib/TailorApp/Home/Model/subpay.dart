class SubscriptionPaymentResponse {
  final bool success;
  final String message;
  final String authorizationUrl;
  final SubscriptionPaymentData data;

  SubscriptionPaymentResponse({
    required this.success,
    required this.message,
    required this.authorizationUrl,
    required this.data,
  });

  factory SubscriptionPaymentResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      authorizationUrl: json['authorizationUrl'] ?? '',
      data: SubscriptionPaymentData.fromJson(json['data']),
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
  final String subscriptionStartDate;
  final String subscriptionEndDate;

  SubscriptionPaymentData({
    required this.id,
    required this.userId,
    required this.plan,
    required this.billTerm,
    required this.paymentStatus,
    required this.totalAmount,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
  });

  factory SubscriptionPaymentData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      plan: json['plan'] ?? '',
      billTerm: json['billTerm'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      subscriptionStartDate: json['subscriptionStartDate'] ?? '',
      subscriptionEndDate: json['subscriptionEndDate'] ?? '',
    );
  }
}
