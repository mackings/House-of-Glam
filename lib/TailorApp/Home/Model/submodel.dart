class SubscriptionPlanResponse {
  final bool success;
  final String message;
  final List<SubscriptionPlan> data;

  SubscriptionPlanResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => SubscriptionPlan.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int amount;
  final String duration;
  final String description;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.duration,
    required this.description,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
