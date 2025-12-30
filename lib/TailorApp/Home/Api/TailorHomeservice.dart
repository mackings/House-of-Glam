import 'dart:convert';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/utils/error_handler.dart';
import 'package:http/http.dart' as http;

class TailorHomeService {
  final String baseUrl = ApiConfig.apiBaseUrl;

  Future<TailorMaterialResponse> fetchTailorMaterials(String s) async {
    try {
      final token = await SecurePrefs.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/material/getAllMaterials'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("➡️ GET Request: $baseUrl/material/getAllMaterials");
      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TailorMaterialResponse.fromJson(jsonData);
      } else {
        final errorMessage = ErrorHandler.parseApiError(response.body, response.statusCode);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("❌ Error fetching tailor materials: $e");
      final friendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      throw Exception(friendlyMessage);
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
    try {
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
        final errorMessage = ErrorHandler.parseApiError(response.body, response.statusCode);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final friendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      throw Exception(friendlyMessage);
    }
  }

  // 🆕 Assigned Materials API
  Future<TailorAssignedMaterialsResponse> fetchAssignedMaterials() async {
    try {
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
        final errorMessage = ErrorHandler.parseApiError(response.body, response.statusCode);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final friendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      throw Exception(friendlyMessage);
    }
  }

  // 🆕 Deliver Attire (Create Tracking)
  Future<String> deliverAttire(String materialId) async {
    try {
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
        final errorMessage = ErrorHandler.parseApiError(response.body, response.statusCode);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final friendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      throw Exception(friendlyMessage);
    }
  }

  Future<String> updateQuotation({
    required String materialId,
    required String comment,
    required String materialTotalCost,
    required String workmanshipTotalCost,
    required String deliveryDate,
    required String reminderDate,
  }) async {
    try {
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

      print("➡️ [Update] $url");
      print("📦 Payload: $body");
      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData["message"] ?? "Quotation updated successfully";
      } else {
        final errorMessage = ErrorHandler.parseApiError(response.body, response.statusCode);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final friendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      throw Exception(friendlyMessage);
    }
  }
}
