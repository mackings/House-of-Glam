import 'dart:convert';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:http/http.dart' as http;

class TailorTrackingService {
  final String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  Future<TailorTrackingResponse> fetchTrackingRecords() async {
    try {
      final token = await SecurePrefs.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/tracking/getAllTracking'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("➡️ GET Request: $baseUrl/tracking/getAllTracking");
      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TailorTrackingResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to fetch tracking records: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching tracking records: $e");
      rethrow;
    }
  }

  // 🆕 Deliver Attire API
  Future<String> deliverAttire(String materialId) async {
    final token = await SecurePrefs.getToken();

    final url = Uri.parse(
      "$baseUrl/tracking/createTracking?materialId=$materialId",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("➡️ POST Request: $url");
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData["message"] ?? "Attire delivered successfully";
    } else {
      throw Exception(responseData["message"] ?? "Failed to deliver attire");
    }
  }
}
