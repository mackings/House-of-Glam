import 'dart:convert';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;

class BillingService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1/admin";

  /// 🔹 Create or Update Listing Fee
  static Future<bool> setListingFee(double amount) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/createListingFee");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"amount": amount}),
      );

      print("➡️ POST $url | Body: {amount: $amount}");
      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error setting listing fee: $e");
      return false;
    }
  }

  /// 🔹 Fetch Current Listing Fee
  static Future<double?> getListingFee() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/getListingFee");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("➡️ GET $url");
      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final list = jsonData['data'] as List;
        if (list.isNotEmpty) {
          return (list.first['amount'] as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      print("❌ Error fetching listing fee: $e");
      return null;
    }
  }
}
