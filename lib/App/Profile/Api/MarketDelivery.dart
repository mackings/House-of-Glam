import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Profile/Model/DeliveryTrack.dart';
import 'package:http/http.dart' as http;



class MarketPlaceDeliveryService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  /// 🔹 Fetch all BUYER tracking records
  static Future<List<MarketTrackingRecord>> getAllTracking() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/buyer/getAllTracking");

      print("➡️ GET Request to: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final records = jsonData["data"] as List;
        return records.map((e) => MarketTrackingRecord.fromJson(e)).toList();
      } else {
        print("⚠️ Failed to fetch tracking records: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching tracking records: $e");
      return [];
    }
  }

  /// 🔹 Fetch all SELLER tracking records
  static Future<List<MarketTrackingRecord>> getAllSellerTracking() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/seller/getAllTracking");

      print("➡️ GET Request to: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final records = jsonData["data"] as List;
        return records.map((e) => MarketTrackingRecord.fromJson(e)).toList();
      } else {
        print("⚠️ Failed to fetch seller tracking records: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching seller tracking records: $e");
      return [];
    }
  }

  /// 🔹 Accept order by tracking number
  static Future<bool> acceptOrder(String trackingNumber) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/buyer/acceptOrder?trackingNumber=$trackingNumber");

      print("➡️ PUT Request to: $url");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error accepting order: $e");
      return false;
    }
  }
}
