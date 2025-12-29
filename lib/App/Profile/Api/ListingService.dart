import 'dart:convert';
import 'dart:io';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/App/Profile/Model/UploadedListings.dart';
import 'package:hog/constants/api_config.dart';
import 'package:http/http.dart' as http;

class MarketplaceService {
  static const String baseUrl = ApiConfig.apiBaseUrl;

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

  /// 🔹 Upload a new seller listing
  static Future<bool> createSellerListing({
    required String categoryId,
    required String title,
    required String size,
    required String description,
    required String condition,
    required String status,
    required double price,
    required List<File> images,
    List<Map<String, dynamic>>? yards, // ✅ optional yards
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      if (token == null) throw Exception("No token found");

      final url = Uri.parse("$baseUrl/seller/sellerCreateListing/$categoryId");
      final request = http.MultipartRequest("POST", url);
      request.headers["Authorization"] = "Bearer $token";

      request.fields["title"] = title;
      request.fields["size"] = size;
      request.fields["description"] = description;
      request.fields["condition"] = condition;
      request.fields["status"] = status;
      request.fields["price"] = price.toString();

      // ✅ Add yards if any
      if (yards != null && yards.isNotEmpty) {
        request.fields["yards"] = jsonEncode(yards);
      }

      for (final imageFile in images) {
        final fileName = imageFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            "images",
            imageFile.path,
            filename: fileName,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error creating listing: $e");
      return false;
    }
  }

  /// 🔹 Fetch seller’s uploaded listings
  static Future<List<UserListing>> getSellerListings() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/seller/getSellerListings");

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
        final data = jsonDecode(response.body);
        final listingsJson = data["data"] as List;
        return listingsJson.map((e) => UserListing.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch listings");
      }
    } catch (e) {
      print("❌ Error fetching seller listings: $e");
      return [];
    }
  }

  /// 🔹 Delete seller listing
  static Future<bool> deleteSellerListing(String listingId) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/seller/deleteSellerListing/$listingId");

      print("➡️ DELETE Request to: $url");

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error deleting listing: $e");
      return false;
    }
  }
}
