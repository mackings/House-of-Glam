import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:http/http.dart' as http;

class PickupLocationOption {
  final String id;
  final String name;
  final String address;
  final bool isActive;

  const PickupLocationOption({
    required this.id,
    required this.name,
    required this.address,
    required this.isActive,
  });

  factory PickupLocationOption.fromJson(Map<String, dynamic> json) {
    return PickupLocationOption(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
      isActive: json["isActive"] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickupLocationOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PickupStateOption {
  final String id;
  final String name;
  final List<PickupLocationOption> locations;

  const PickupStateOption({
    required this.id,
    required this.name,
    required this.locations,
  });

  factory PickupStateOption.fromJson(Map<String, dynamic> json) {
    final rawLocations = (json["locations"] as List?) ?? const [];
    return PickupStateOption(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      locations:
          rawLocations
              .whereType<Map>()
              .map((e) => PickupLocationOption.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickupStateOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PickupCountryOption {
  final String id;
  final String name;
  final List<PickupStateOption> states;

  const PickupCountryOption({
    required this.id,
    required this.name,
    required this.states,
  });

  factory PickupCountryOption.fromJson(Map<String, dynamic> json) {
    final rawStates = (json["states"] as List?) ?? const [];
    return PickupCountryOption(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      states:
          rawStates
              .whereType<Map>()
              .map((e) => PickupStateOption.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickupCountryOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PaymentService {
  static const String localBaseURL = ApiConfig.apiBaseUrl;
  static const String liveBaseURL = ApiConfig.apiBaseUrl;

  static void _logPaymentResponse({
    required String label,
    required Uri url,
    required Map<String, dynamic> payload,
    required Map<String, String> headers,
    required http.Response response,
  }) {
    print("➡️ $label Request URL: $url");
    print("📦 $label Payload: $payload");
    print("🧾 $label Headers: $headers");
    print("⬅️ $label Response Status: ${response.statusCode}");
    print("📨 $label Response Headers: ${response.headers}");
    print("📨 $label Response Body: ${response.body}");
  }

  static Map<String, String> _buildHeaders(String? token) {
    return {
      "Authorization": "Bearer ${token ?? ''}",
      "Content-Type": "application/json",
    };
  }

  /// Calculate Delivery Cost
  static Future<Map<String, dynamic>?> calculateDeliveryCost({
    required String reviewId,
    required String shipmentMethod,
    String? address,
    String? pickupCountryId,
    String? pickupStateId,
    String? pickupLocationId,
  }) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse(
      "$localBaseURL/deliveryRate/deliveryCost/$reviewId",
    );

    final payload = {
      "shipmentMethod": shipmentMethod,
      if (address != null && address.isNotEmpty) "address": address,
      if (pickupCountryId != null) "pickupCountryId": pickupCountryId,
      if (pickupStateId != null) "pickupStateId": pickupStateId,
      if (pickupLocationId != null) "pickupLocationId": pickupLocationId,
    };

    try {
      final headers = _buildHeaders(token);
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      _logPaymentResponse(
        label: "Delivery Cost",
        url: url,
        payload: payload,
        headers: headers,
        response: response,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Delivery Cost Parsed Response: $data");
        return data;
      } else {
        print("❌ Delivery Cost Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error Delivery Cost: $e");
      return null;
    }
  }

  /// Get full pickup hierarchy (country -> state -> locations)
  static Future<List<PickupCountryOption>> getPickupHierarchy() async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$localBaseURL/deliveryRate/pickup/hierarchy");

    try {
      final headers = _buildHeaders(token);
      final response = await http.get(url, headers: headers);

      _logPaymentResponse(
        label: "Pickup Hierarchy",
        url: url,
        payload: const <String, dynamic>{},
        headers: headers,
        response: response,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final raw = (decoded["data"] as List?) ?? const [];
        return raw
            .whereType<Map>()
            .map((e) => PickupCountryOption.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return const [];
    } catch (e) {
      print("❌ Error fetching pickup hierarchy: $e");
      return const [];
    }
  }

  /// Create Part Payment (Using unified endpoint with paymentStatus)
  static Future<Map<String, dynamic>?> createPartPayment({
    required String reviewId,
    required String amount,
    required String shipmentMethod,
    String? address,
    String? pickupCountryId,
    String? pickupStateId,
    String? pickupLocationId,
  }) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse(
      "$localBaseURL/material/createPaymentOnline/$reviewId",
    );

    final payload = {
      "amount": amount,
      "shipmentMethod": shipmentMethod,
      "paymentStatus": "part payment",
      if (address != null) "address": address,
      if (pickupCountryId != null) "pickupCountryId": pickupCountryId,
      if (pickupStateId != null) "pickupStateId": pickupStateId,
      if (pickupLocationId != null) "pickupLocationId": pickupLocationId,
    };

    try {
      final headers = _buildHeaders(token);
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      _logPaymentResponse(
        label: "Part Payment",
        url: url,
        payload: payload,
        headers: headers,
        response: response,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Part Payment Parsed Response: $data");
        return data;
      } else {
        print("❌ Part Payment Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error Part Payment: $e");
      return null;
    }
  }

  /// Create Full Payment (Using unified endpoint with paymentStatus)
  static Future<Map<String, dynamic>?> createFullPayment({
    required String reviewId,
    required String amount,
    required String shipmentMethod,
    String? address,
    String? pickupCountryId,
    String? pickupStateId,
    String? pickupLocationId,
  }) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse(
      "$liveBaseURL/material/createPaymentOnline/$reviewId",
    );

    final payload = {
      "amount": amount,
      "shipmentMethod": shipmentMethod,
      "paymentStatus": "full payment",
      if (address != null) "address": address,
      if (pickupCountryId != null) "pickupCountryId": pickupCountryId,
      if (pickupStateId != null) "pickupStateId": pickupStateId,
      if (pickupLocationId != null) "pickupLocationId": pickupLocationId,
    };

    try {
      final headers = _buildHeaders(token);
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      _logPaymentResponse(
        label: "Full Payment",
        url: url,
        payload: payload,
        headers: headers,
        response: response,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Full Payment Parsed Response: $data");
        return data;
      } else {
        print("❌ Full Payment Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error Full Payment: $e");
      return null;
    }
  }
}
