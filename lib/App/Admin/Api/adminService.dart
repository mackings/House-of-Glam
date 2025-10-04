import 'dart:convert';

import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1/admin";

  /// Fetch all pending seller listings
  static Future<List<PendingSellerListing>> getAllPendingListings() async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$baseUrl/getAllPendingSellerListings");

    try {
      print("➡️ GET $url");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData["data"] as List;
        return data.map((e) => PendingSellerListing.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load pending listings");
      }
    } catch (e) {
      print("❌ Error fetching pending listings: $e");
      return [];
    }
  }

  /// Approve a seller listing
  static Future<bool> approveListing(String listingId) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$baseUrl/approveSellerListing/$listingId");

    try {
      final response = await http.put(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      print("✅ Approve Response [${response.statusCode}]: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error approving listing: $e");
      return false;
    }
  }

  /// Reject a seller listing
  static Future<bool> rejectListing(String listingId, String reason) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$baseUrl/rejectSellerListing/$listingId");

    try {
      final response = await http.put(url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"reasons": reason}));

      print("🚫 Reject Response [${response.statusCode}]: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error rejecting listing: $e");
      return false;
    }
  }
}
