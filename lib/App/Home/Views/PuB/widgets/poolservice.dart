import 'dart:convert';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:http/http.dart' as http;

extension PatronizePublished on PublishedService {
  Future<void> patronizePublished({
    required String publishedId,
    required Map<String, dynamic> measurement,
    required String specialInstructions,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse(
        "$baseUrl/published/userPatronizedPublished/$publishedId",
      );

      final body = jsonEncode({
        "measurement": [measurement],
        "specialInstructions": specialInstructions,
      });

      print("➡️ POST Request: $url");
      print("📦 Body: $body");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          "Failed to patronize published cloth: ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Error patronizing published cloth: $e");
      rethrow;
    }
  }
}
