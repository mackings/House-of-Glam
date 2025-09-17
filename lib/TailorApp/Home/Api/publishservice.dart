import 'dart:convert';
import 'dart:io';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:http/http.dart' as http;

class PublishedService {

  final String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  Future<void> createPublished({
    required String categoryId,
    required String attireType,
    required String clothPublished,
    required String color,
    required String brand,
    required List<File> images,
  }) async {
    try {
      final token = await SecurePrefs.getToken();

      var uri = Uri.parse('$baseUrl/published/createPublished/$categoryId');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['attireType'] = attireType
        ..fields['clothPublished'] = clothPublished
        ..fields['color'] = color
        ..fields['brand'] = brand;

      for (var img in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', img.path),
        );
      }

      print("➡️ POST Request: $uri");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception("Failed to publish cloth: ${response.body}");
      }
    } catch (e) {
      print("❌ Error creating published cloth: $e");
      rethrow;
    }
  }


    // ✅ New getAllPublished
    
  Future<TailorPublishedResponse> getAllPublished() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/published/getAllPublished");

      print("➡️ GET Request: $url");

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TailorPublishedResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to fetch published cloths: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching published cloths: $e");
      rethrow;
    }
  }
}
