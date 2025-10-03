import 'dart:convert';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:http/http.dart' as http;

class MarketplaceService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  /// 🔹 Fetch all seller listings
  static Future<SellerListingResponse?> getAllSellerListings() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/buyer/getAlSellerListings");

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
        return SellerListingResponse.fromJson(jsonData);
      } else {
        print("⚠️ Failed to fetch listings: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching seller listings: $e");
    }
    return null;
  }
}