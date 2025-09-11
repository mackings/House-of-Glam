import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/useractivitymodel.dart';

class UserActivityService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  /// Create Material (upload with multipart)
  static Future<MaterialResponse?> createMaterial({
    required String clothMaterial,
    required String color,
    required String brand,
    required double price,
    required List<File> images,
    required String deliveryDate,
    required String reminderDate,
    required String specialInstructions,
    required Map<String, dynamic> measurement,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final attireId = await SecurePrefs.getAttireId(); // store attireId in prefs

      final url = Uri.parse("$baseUrl/material/createMaterial/$attireId");

      var request = http.MultipartRequest("POST", url);

      // 🔑 Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // 📝 Text fields
      request.fields["clothMaterial"] = clothMaterial;
      request.fields["color"] = color;
      request.fields["brand"] = brand;
      request.fields["prices"] = price.toString();
      request.fields["deliveryDate"] = deliveryDate;
      request.fields["reminderDate"] = reminderDate;
      request.fields["specialinstructions"] = specialInstructions;

      // 🧵 Measurement JSON
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MaterialResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error creating material: $e");
    }

    return null;
  }
}