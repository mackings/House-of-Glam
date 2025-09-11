
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';




class ReviewService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  /// Get all reviews
  static Future<ReviewResponse?> getReviews() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/review/getReviews");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ReviewResponse.fromJson(jsonData);
      } else {
        print("❌ Failed to fetch reviews: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching reviews: $e");
    }
    return null;
  }
}