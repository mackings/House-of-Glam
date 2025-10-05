import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:http/http.dart' as http;

class TrackingService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  /// 🔹 Fetch all tracking records
  static Future<TrackingResponse?> getAllTracking() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/tracking/getAllTracking");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrackingResponse.fromJson(jsonData);
      }
    } catch (e) {
      print("❌ Error fetching tracking: $e");
    }
    return null;
  }

  /// 🔹 Update material through tracking
  static Future<bool> updateMaterialThroughTracking(int trackingNumber) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse(
        "$baseUrl/tracking/updateMaterialThroughTracking?trackingNumber=$trackingNumber",
      );

      print("➡️ PUT Request to: $url");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("❌ Error updating material: $e");
    }
    return false;
  }
}
