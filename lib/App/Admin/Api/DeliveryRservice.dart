
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;


class DeliveryRateService {
  static const String baseUrl =
      "https://hog-ymud.onrender.com/api/v1/deliveryRate";

  /// 🧩 Helper for safe API requests with retry and timeout
  static Future<http.Response?> _safeRequest(Future<http.Response> Function() request) async {
    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await request().timeout(const Duration(seconds: 10));
        return response;
      } on SocketException catch (e) {
        print("🌐 Network error on attempt ${attempt + 1}: $e");
      } on HttpException catch (e) {
        print("⚠️ HTTP error on attempt ${attempt + 1}: $e");
      } on FormatException catch (e) {
        print("⚠️ Format error on attempt ${attempt + 1}: $e");
      } on TimeoutException {
        print("⏳ Timeout on attempt ${attempt + 1}");
      }

      attempt++;
      await Future.delayed(Duration(seconds: 1 * attempt)); // exponential backoff
    }
    print("🚫 All retry attempts failed.");
    return null;
  }

  /// 🔹 Create a new Delivery Rate
  static Future<bool> createDeliveryRate({
    required double amount,
    required String deliveryType,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/createDeliveryRate");

      print("➡️ POST $url");
      print("📦 Payload: { amount: $amount, deliveryType: $deliveryType }");

      final response = await _safeRequest(() => http.post(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "amount": amount.toString(),
              "deliveryType": deliveryType,
            }),
          ));

      if (response == null) return false;

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      }
      return false;
    } catch (e) {
      print("❌ Error creating delivery rate: $e");
      return false;
    }
  }

  /// 🔹 Get all Delivery Rates
  static Future<List<Map<String, dynamic>>> getDeliveryRates() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/getDeliveryRates");

      print("➡️ GET $url");

      final response = await _safeRequest(() => http.get(url, headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          }));

      if (response == null) return [];

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data["deliveryRates"] as List;
        return List<Map<String, dynamic>>.from(rates);
      }
      return [];
    } catch (e) {
      print("❌ Error fetching delivery rates: $e");
      return [];
    }
  }

  /// 🔹 Update Delivery Rate
  static Future<bool> updateDeliveryRate({
    required String rateId,
    required double amount,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/updateDeliveryRate/$rateId");

      print("➡️ PUT $url");
      print("📦 Payload: { amount: $amount }");

      final response = await _safeRequest(() => http.put(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"amount": amount.toString()}),
          ));

      if (response == null) return false;

      print("⬅️ Response [${response.statusCode}]: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error updating delivery rate: $e");
      return false;
    }
  }

  /// 🔹 Delete Delivery Rate
  static Future<bool> deleteDeliveryRate(String rateId) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/deleteDeliveryRate/$rateId");

      print("➡️ DELETE $url");

      final response = await _safeRequest(() => http.delete(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          ));

      if (response == null) return false;

      print("⬅️ Response [${response.statusCode}]: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error deleting delivery rate: $e");
      return false;
    }
  }

  /// 🔹 Estimate Delivery Cost
  static Future<double?> estimateDeliveryCost({
    required String userId,
    required String shipmentMethod,
    required String address,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse(
        "https://hog-ymud.onrender.com/api/v1/deliveryRate/deliveryCost/$userId",
      );

      print("➡️ POST $url");
      print("📦 Payload: { shipmentMethod: $shipmentMethod, address: $address }");

      final response = await _safeRequest(() => http.post(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "shipmentMethod": shipmentMethod,
              "address": address,
            }),
          ));

      if (response == null) return null;

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data["cost"] as num).toDouble();
      }
      return null;
    } catch (e) {
      print("❌ Error estimating delivery cost: $e");
      return null;
    }
  }
}
