/// A single live shipping rate returned by Fez Delivery for a given order,
/// via POST /deliveryRate/carrier-rates/:reviewId. Fez auto-detects the
/// route from the vendor's and buyer's country profile fields:
/// - both in Nigeria      -> FEZ_STANDARD (domestic)
/// - vendor NG, buyer abroad -> FEZ_EXPORT
/// - vendor abroad, buyer NG -> FEZ_IMPORT
/// Each route normally returns exactly one rate, not several selectable
/// service tiers the way FedEx did.
class CarrierRate {
  final String carrier;
  final String serviceType;
  final String serviceName;
  final double amount;
  final double? baseAmount;
  final double? vatAmount;
  final double? vatPercent;
  final String currency;
  final String? state;
  final String? destination;
  final String? origin;

  const CarrierRate({
    required this.carrier,
    required this.serviceType,
    required this.serviceName,
    required this.amount,
    this.baseAmount,
    this.vatAmount,
    this.vatPercent,
    required this.currency,
    this.state,
    this.destination,
    this.origin,
  });

  factory CarrierRate.fromJson(Map<String, dynamic> json) {
    return CarrierRate(
      carrier: (json['carrier'] ?? 'fez').toString(),
      serviceType: (json['serviceType'] ?? '').toString(),
      serviceName: (json['serviceName'] ?? '').toString(),
      amount: _asDouble(json['amount']),
      baseAmount:
          json['baseAmount'] != null ? _asDouble(json['baseAmount']) : null,
      vatAmount:
          json['vatAmount'] != null ? _asDouble(json['vatAmount']) : null,
      vatPercent:
          json['vatPercent'] != null ? _asDouble(json['vatPercent']) : null,
      // Fez returns an ISO code for domestic/export (e.g. "NGN") but a raw
      // currency symbol for import (e.g. "£") — kept as-is either way and
      // handled at display time by CurrencyHelper.
      currency: (json['currency'] ?? 'NGN').toString(),
      state: json['state']?.toString(),
      destination: json['destination']?.toString(),
      origin: json['origin']?.toString(),
    );
  }

  /// baseAmount/amount sometimes come back as JSON strings rather than
  /// numbers (seen on export/import routes), so parse defensively either way.
  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Short route context shown alongside the fee, since Fez doesn't return
  /// a transit-time estimate the way FedEx did.
  String get routeLabel {
    if (destination != null && destination!.isNotEmpty) {
      return 'Ships to $destination';
    }
    if (origin != null && origin!.isNotEmpty) {
      return 'Ships from $origin';
    }
    if (state != null && state!.isNotEmpty) {
      return 'Delivering to $state';
    }
    return 'Fez Delivery';
  }
}

/// Response wrapper for POST /deliveryRate/carrier-rates/:reviewId.
///
/// Fez reports failures (unsupported route, missing buyer state, unsupported
/// country, review not found) as non-2xx responses carrying a top-level
/// `message`, and sometimes also a carrier-specific `carrierErrors.fez`
/// message alongside an empty `rates` array. Both are surfaced through
/// [displayError] so the UI always has something concrete to show instead
/// of a generic "no rates" message.
class CarrierRatesResult {
  final List<CarrierRate> rates;
  final Map<String, String> carrierErrors;
  final String? errorMessage;

  const CarrierRatesResult({
    this.rates = const [],
    this.carrierErrors = const {},
    this.errorMessage,
  });

  factory CarrierRatesResult.fromJson(Map<String, dynamic> json) {
    final rawRates = (json['rates'] as List?) ?? const [];
    final rawErrors = json['carrierErrors'];
    final rates =
        rawRates
            .whereType<Map>()
            .map((e) => CarrierRate.fromJson(Map<String, dynamic>.from(e)))
            .toList();

    // The backend reports a failed/empty quote both as `success: false` with
    // a `message` (hard validation errors like an unsupported route) AND as
    // `success: true` with `rates: []` plus a `message` like "No rates
    // available" (a soft failure, e.g. Fez itself rejected the request).
    // Grab the message whenever there are no usable rates either way —
    // relying on `success` alone silently dropped that second case and left
    // the UI showing a vague generic fallback instead of the real reason.
    final message = rates.isEmpty ? json['message']?.toString() : null;

    return CarrierRatesResult(
      rates: rates,
      carrierErrors:
          rawErrors is Map
              ? rawErrors.map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              )
              : const {},
      errorMessage: message,
    );
  }

  bool get hasRates => rates.isNotEmpty;

  /// The best available explanation for why no rates came back, in priority
  /// order: a carrier-specific message, then the response's top-level
  /// message, then a generic fallback.
  String get displayError {
    if (carrierErrors.values.isNotEmpty) return carrierErrors.values.first;
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return errorMessage!;
    }
    return "This route isn't supported yet.";
  }
}
