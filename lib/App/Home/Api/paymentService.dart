import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:http/http.dart' as http;

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

  /// Create Part Payment (Using unified endpoint with paymentStatus)
  static Future<Map<String, dynamic>?> createPartPayment({
    required String reviewId,
    required String amount,
    required String shipmentMethod,
    String? address,
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
