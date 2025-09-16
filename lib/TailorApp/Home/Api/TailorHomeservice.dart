import 'dart:convert';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:http/http.dart' as http ;

class TailorHomeService {
  final String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  Future<TailorMaterialResponse> fetchTailorMaterials(String s) async {
    try {
      final token = await SecurePrefs.getToken(); // 🔹 retrieve token

      final response = await http.get(
        Uri.parse('$baseUrl/material/getAllMaterials'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // 🔹 attach token
        },
      );

      print("➡️ GET Request: $baseUrl/material/getAllMaterials");
      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TailorMaterialResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to fetch tailor materials: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching tailor materials: $e");
      rethrow;
    }
  }


  // Submit quotation
Future<void> submitQuotation({
  required String materialId,
  required String comment,
  required String materialTotalCost,
  required String workmanshipTotalCost,
  required String deliveryDate,
  required String reminderDate,
}) async {
  final token = await SecurePrefs.getToken();

  final url = Uri.parse("$baseUrl/review/createReview/$materialId");

  final body = json.encode({
    "comment": comment,
    "materialTotalCost": materialTotalCost,
    "workmanshipTotalCost": workmanshipTotalCost,
    "deliveryDate": deliveryDate,
    "reminderDate": reminderDate,
  });

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: body,
  );

  print("➡️ POST Request: $url");
  print("⬅️ Response [${response.statusCode}]: ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to submit quotation: ${response.body}");
  }
}



  // 🆕 Assigned Materials API
  Future<TailorAssignedMaterialsResponse> fetchAssignedMaterials() async {
    final token = await SecurePrefs.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/tailor/getAllAssignedMaterials'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("➡️ GET Request: $baseUrl/tailor/getAllAssignedMaterials");
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return TailorAssignedMaterialsResponse.fromJson(jsonData);
    } else {
      throw Exception("Failed to fetch assigned materials: ${response.body}");
    }
  }
}
