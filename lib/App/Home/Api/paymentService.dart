import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String localBaseURL = "https://hog-ymud.onrender.com/api/v1";
  static const String liveBaseURL = "https://hog-ymud.onrender.com/api/v1";

  /// Create Part Payment
  static Future<Map<String, dynamic>?> createPartPayment({
    required String reviewId,
    required String amount,
    required String shipmentMethod,
  }) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse(
      "$localBaseURL/material/createPartPaymentOnline/$reviewId",
    );

    final payload = {"amount": amount, "shipmentMethod": shipmentMethod};

    print("➡️ Part Payment Request: $payload");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print(
        "⬅️ Part Payment Response [${response.statusCode}]: ${response.body}",
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

  /// Create Full Payment
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
      "address": address,
    };

    print("➡️ Full Payment Request: $payload");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print(
        "⬅️ Full Payment Response [${response.statusCode}]: ${response.body}",
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
