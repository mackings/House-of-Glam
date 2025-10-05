import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/TailorApp/Home/Model/subpay.dart';
import 'package:http/http.dart' as http;

class SubscriptionService {
  final String baseUrl = "https://hog-ymud.onrender.com/api/v1/subscription";

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
    required String plan,
    required String amount,
    required String billTerm, // monthly, quarterly, yearly
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/subscriptionPayments");

      final body = {"plan": plan, "amount": amount, "billTerm": billTerm};

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
}
