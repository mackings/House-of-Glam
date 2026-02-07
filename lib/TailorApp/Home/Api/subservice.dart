import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/TailorApp/Home/Model/subpay.dart';
import 'package:http/http.dart' as http;

class SubscriptionService {
  final String baseUrl = "${ApiConfig.apiBaseUrl}/subscription";

  // ✅ Get all subscription plans
  Future<SubscriptionPlanResponse> getSubscriptionPlans() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/getSubscriptionPlans");

      print("➡️ GET Request: $url");

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SubscriptionPlanResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to fetch subscription plans: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching subscription plans: $e");
      rethrow;
    }
  }

  // ✅ Subscribe to a plan
  Future<SubscriptionPaymentResponse> subscribeToPlan({
    String? planId,
    String? plan,
    String? billTerm,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/subscriptionPayments");

      final body = {
        if (planId != null) "planId": planId,
        if (planId == null && plan != null) "plan": plan,
        if (planId == null && billTerm != null) "billTerm": billTerm,
      };

      print("➡️ POST Request: $url with body $body");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return SubscriptionPaymentResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to subscribe: ${response.body}");
      }
    } catch (e) {
      print("❌ Error subscribing: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> createSubscriptionPlan({
    required String name,
    required int amount,
    required String duration,
    required String description,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/createSubscriptionPlan");
      final body = {
        "name": name,
        "amount": amount,
        "duration": duration,
        "description": description,
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateSubscriptionPlan({
    required String id,
    String? name,
    int? amount,
    String? duration,
    String? description,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/updateSubscriptionPlan/$id");
      final body = {
        if (name != null) "name": name,
        if (amount != null) "amount": amount,
        if (duration != null) "duration": duration,
        if (description != null) "description": description,
      };

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteSubscriptionPlan(String id) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/deleteSubscriptionPlan/$id");
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<SubscriptionPlan?> getSubscriptionPlan(String id) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/getSubscriptionPlan/$id");
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData["data"];
        if (data is Map<String, dynamic>) {
          return SubscriptionPlan.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
