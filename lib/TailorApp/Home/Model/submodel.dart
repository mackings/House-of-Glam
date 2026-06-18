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
    final rawData = json['data'];
    return SubscriptionPlanResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          rawData is List
              ? rawData
                  .whereType<Map<String, dynamic>>()
                  .map(SubscriptionPlan.fromJson)
                  .toList()
              : [],
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int amount;
  final String duration;
  final String description;
  final List<String> benefits;
  final int benefitCount;
  final String baseCurrency;
  final String displayCurrency;
  final double displayAmount;
  final double exchangeRate;
  final String paymentProvider;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.duration,
    required this.description,
    this.benefits = const [],
    this.benefitCount = 0,
    this.baseCurrency = 'NGN',
    this.displayCurrency = 'NGN',
    this.displayAmount = 0,
    this.exchangeRate = 0,
    this.paymentProvider = '',
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
      return text;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final rawDisplay = json['displayAmount'];
    final parsedDisplay =
        rawDisplay is num
            ? rawDisplay.toDouble()
            : double.tryParse(rawDisplay?.toString() ?? '') ?? 0;
    final rawRate = json['exchangeRate'];
    final parsedRate =
        rawRate is num
            ? rawRate.toDouble()
            : double.tryParse(rawRate?.toString() ?? '') ?? 0;

    final benefits =
        json['benefits'] is List
            ? (json['benefits'] as List)
                .map((benefit) => parseString(benefit))
                .where((benefit) => benefit.isNotEmpty)
                .toList()
            : const <String>[];
    final parsedBenefitCount = parseInt(json['benefitCount']);

    return SubscriptionPlan(
      id: parseString(json['_id']),
      name: parseString(json['name']),
      amount: parseInt(json['amount']),
      duration: parseString(json['duration']),
      description: parseString(json['description']),
      benefits: benefits,
      benefitCount:
          parsedBenefitCount > 0 ? parsedBenefitCount : benefits.length,
      baseCurrency: parseString(json['baseCurrency'], fallback: 'NGN'),
      displayCurrency: parseString(json['displayCurrency'], fallback: 'NGN'),
      displayAmount: parsedDisplay,
      exchangeRate: parsedRate,
      paymentProvider: parseString(json['paymentProvider']),
    );
  }
}
