import 'dart:convert';
import 'dart:io';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/useractivitymodel.dart';
import 'package:hog/utils/session_expiry_handler.dart';

class UserActivityService {
  static const String baseUrl = ApiConfig.apiBaseUrl;

  static Future<MaterialResponse?> createMaterial({
    required String clothMaterial,
    required String color,
    required String brand,
    required List<File> images,
    required String specialInstructions,
    required Map<String, dynamic> measurement,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final attireId = await SecurePrefs.getAttireId();

      final url = Uri.parse("$baseUrl/material/createMaterial/$attireId");

      var request = http.MultipartRequest("POST", url);

      // 🔑 Headers
      request.headers.addAll({"Authorization": "Bearer $token"});

      // 📝 Text fields
      request.fields["clothMaterial"] = clothMaterial;
      request.fields["color"] = color;
      request.fields["brand"] = brand;
      request.fields["specialinstructions"] = specialInstructions;
      request.fields["measurement"] = jsonEncode([measurement]);

      // 🖼️ Images
      for (var img in images) {
        request.files.add(
          await http.MultipartFile.fromPath("images", img.path),
        );
      }

      print("➡️ POST Request: $url");
      print("📦 Fields: ${request.fields}");
      print("🖼️ Images: ${images.map((e) => e.path).toList()}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MaterialResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error creating material: $e");
    }

    return null;
  }

  static Future<MaterialReviewResponse?> getAllMaterialsForReview() async {
    try {
      final token = await SecurePrefs.getToken();

      final url = Uri.parse("$baseUrl/review/getAllMaterialsForReview");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("➡️ GET Request: $url");
      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return null;
      }

      if (response.statusCode == 200) {
        return MaterialReviewResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error fetching materials for review: $e");
    }
    return null;
  }

  static Future<ReviewResponse?> getReviewsForMaterialById(
    String materialId,
  ) async {
    try {
      final token = await SecurePrefs.getToken();

      final url = Uri.parse(
        "$baseUrl/review/getReviewsForMaterialById/$materialId",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("➡️ GET Request: $url");
      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return null;
      }

      if (response.statusCode == 200) {
        return ReviewResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error fetching reviews: $e");
    }
    return null;
  }
}
